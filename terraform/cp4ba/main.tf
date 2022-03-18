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
  source = "../../../terraform-ibm-cloud-pak/modules/roks"
//  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"

  enable               = local.enable_cluster
  on_vpc               = var.on_vpc
  project_name         = var.roks_project
  environment          = var.environment
  owner                = var.owner
  resource_group       = var.resource_group
  roks_version         = var.platform_version
  entitlement          = var.entitlement
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter           = var.data_center
  force_delete_storage = true
  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
  vpc_zone_names       = var.vpc_zone_names
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  # Use var.cluster_id if it is NOT blank else use module.create_cluster.id
//  cluster_name_id      = var.cluster_id != null ? var.cluster_id : module.create_cluster.id
  cluster_name_id      = local.enable_cluster ? module.create_cluster.id : var.cluster_id
  resource_group_id    = data.ibm_resource_group.group.id
  download             = true
  config_dir           = var.cluster_config_path
  admin                = false
  network              = false
}

# --------------- PROVISION DB2  ------------------
module "install_db2" {
  source     = "../../../terraform-ibm-cloud-pak/modules/Db2"
//  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2"
    depends_on = [
    module.create_cluster
  ]

  enable_db2 = var.enable_db2
  resource_group           = var.resource_group
  # ----- Cluster -----
  cluster_config_path      = data.ibm_container_cluster_config.cluster_config.config_file_path
  db2_project_name         = var.db2_project_name
  db2_admin_username       = var.db2_admin_username
  db2_admin_user_password  = var.db2_admin_user_password
  db2_standard_license_key = var.db2_standard_license_key
  operatorVersion          = var.operatorVersion
  operatorChannel          = var.operatorChannel
  db2_instance_version     = var.db2_instance_version
  db2_cpu                  = var.db2_cpu
  db2_memory               = var.db2_memory
  db2_storage_size         = var.db2_storage_size
  db2_storage_class        = var.db2_storage_class
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key    = var.entitled_registry_key
}

resource "null_resource" "create_DB_Schema" {

  depends_on = [
    module.install_db2
  ]

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createAPPDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createBASDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createBAWDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createDBSchema.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createGCDDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createICNDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createOSDB.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/db2_schema/createUMSDB.sh"
  }
}

  # ------ CP4BA -------
module "install_cp4ba"{
  source = "../../../terraform-ibm-cloud-pak/modules/cp4ba"
//  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba"
    depends_on = [
    null_resource.create_DB_Schema
  ]
  enable_cp4ba           = var.enable_cp4ba
  ibmcloud_api_key       = var.ibmcloud_api_key
  region                 = var.region
  cluster_config_path    = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain      = var.cluster_ingress_subdomain != null ? var.cluster_ingress_subdomain : module.create_cluster.ingress_hostname
  # ---- Platform ----
  cp4ba_project_name     = var.cp4ba_project_name
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key        = var.entitled_registry_key
  # ----- LDAP Settings -----
  ldap_admin_name         = var.ldap_admin_name
  ldap_admin_password     = var.ldap_admin_password
  # ----- DB2 Settings -----
  db2_host_port           = var.db2_host_port != null ? var.db2_host_port : module.install_db2.db2_ports # var.db2_port_number
  db2_host_address        = var.db2_host_address != null ? var.db2_host_address : module.install_db2.db2_host_address
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password = var.db2_admin_user_password
}

data "external" "get_endpoints" {
  count = var.enable_db2 ? 1 : 0

  depends_on = [
    module.install_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig     = var.cluster_config_path
    namespace      = var.cp4ba_project_name
  }
}