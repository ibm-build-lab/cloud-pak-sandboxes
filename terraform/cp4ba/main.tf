# Provider block
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

module "create_cluster" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"
//  source = "../../../terraform-ibm-cloud-pak/modules/roks"
  enable               = local.enable_cluster
  on_vpc               = false
  project_name         = var.roks_project
  environment          = var.environment
  owner                = var.owner
  resource_group       = var.resource_group
  roks_version         = var.platform_version
  entitlement          = "cloud_pak"
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter           = var.data_center
  force_delete_storage = true
  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
}


resource "time_sleep" "wait_30_min" {
  depends_on = [module.create_cluster]

  create_duration = "1800s"
}

resource "time_sleep" "wait_10_min" {
  depends_on = [module.create_cluster]

  create_duration = "600s"
}


resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id      = local.enable_cluster ? module.create_cluster.name : var.cluster_id
  resource_group_id    = module.create_cluster.resource_group.id
  download             = true
  config_dir           = var.cluster_config_path
  admin                = false
  network              = false
}


# --------------- PROVISION DB2  ------------------
module "install_db2" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2"
//  source = "../../../terraform-ibm-cloud-pak/modules/Db2"
  depends_on = [time_sleep.wait_30_min]


  ibmcloud_api_key         = var.ibmcloud_api_key
  region                   = var.region
  resource_group           = var.resource_group
  # ----- Cluster -----
  cluster_id               = local.enable_cluster ? module.create_cluster.id : var.cluster_id
  cluster_config_path      = data.ibm_container_cluster_config.cluster_config.config_file_path # config_dir
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key    = var.entitled_registry_key
  enable_db2               = var.enable_db2
  db2_project_name         = var.db2_project_name
  db2_name                 = var.db2_name
  db2_admin_username       = var.db2_admin_username
  db2_admin_user_password  = var.db2_admin_user_password
  db2_standard_license_key = var.db2_standard_license_key
  operatorVersion          = var.db2_operator_version
  operatorChannel          = var.db2_operator_channel
  db2_instance_version     = var.db2_instance_version
  db2_cpu                  = var.db2_cpu
  db2_memory               = var.db2_memory
  db2_storage_size         = var.db2_storage_size
  db2_storage_class        = var.db2_storage_class
}


resource "null_resource" "create_DB_Schemas" {

  depends_on = [
    module.install_db2, [time_sleep.wait_10_min]
  ]

  triggers = {
    ic_api_key = var.ibmcloud_api_key
    cluster_id = data.ibm_container_cluster_config.cluster_config.cluster_name_id
    db2_name   = var.db2_name
    db2_user   = var.db2_user
  }

  count = var.enable_db2_schemas ? 1 : 0

  provisioner "local-exec" {
    command = "./exec_db2_pod.sh"
    working_dir = "${path.module}/db2_schemas/"

    environment = {
      IC_API_KEY       = var.ibmcloud_api_key
      CLUSTER_ID       = data.ibm_container_cluster_config.cluster_config.cluster_name_id
      KUBECONFIG       = data.ibm_container_cluster_config.cluster_config.config_file_path
      DB2_DEFAULT_NAME = var.db2_name
      DB2_USER         = var.db2_user
      DB2_PROJECT_NAME = var.db2_project_name
      DB2_POD_NAME     = module.install_db2.db2_pod_name # local.db2_pod_name
    }
  }
}

//  # ------ CP4BA -------
module "install_cp4ba"{
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba"
//  source = "../../../terraform-ibm-cloud-pak/modules/cp4ba"

    depends_on = [
    null_resource.create_DB_Schemas
  ]

  ibmcloud_api_key       = var.ibmcloud_api_key
  region                 = var.region
  resource_group         = data.ibm_resource_group.group.name
  cluster_id             = local.enable_cluster ? module.create_cluster.id : var.cluster_id
  cluster_config_path    = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain      = var.cluster_ingress_subdomain != null ? var.cluster_ingress_subdomain : module.create_cluster.ingress_hostname
  # ---- CP4BA ----
  enable_cp4ba           = local.enable_cp4ba
  cp4ba_project_name     = var.cp4ba_project_name
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key   = var.entitled_registry_key
  # ----- LDAP Settings -----
  ldap_admin_name         = var.ldap_admin_name
  ldap_admin_password     = var.ldap_admin_password
  ldap_host_ip            = var.ldap_host_ip
  # ----- DB2 Settings -----
  enable_db2              = var.enable_db2
  db2_project_name        = var.db2_project_name
  db2_admin_username      = var.db2_admin_username
  db2_user                = var.db2_user
  db2_admin_user_password = var.db2_admin_user_password
  db2_host_address        = var.enable_db2 == false ? local.db2_host_address : module.install_db2.db2_host_address
  db2_ports               = var.enable_db2 == false ? local.db2_ports : module.install_db2.db2_ports
}

