# Provider block
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

module "create_cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/terraform-0.13/modules/roks"

  enable               = local.enable_cluster
  on_vpc               = var.on_vpc
  project_name         = var.project_name
  environment          = var.environment
  owner                = var.owner
  resource_group       = var.resource_group
  roks_version         = var.platform_version
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter           = var.data_center
  force_delete_storage = true
  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
}

# getting and creation a directory for the cluster config file
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_or_id   = var.cluster_id
  resource_group_id    = data.ibm_resource_group.group.id
  download             = true
  config_dir           = var.cluster_config_path
  admin                = false
  network              = false
}

# --------------- PROVISION DB2  ------------------
module "install_db2" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/terraform-0.13/modules/Db2"
    depends_on = [
    module.create_cluster
  ]

  # ----- Cluster -----
  kubeconfig = var.cluster_config_path

  # ----- Platform -----
  enable_db2              = var.enable_db2
  db2_project_name        = var.db2_project_name
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password  = var.db2_admin_password

  # -------- Docker Information ----------
  entitled_registry_key          = var.entitled_registry_key
  entitlement_registry_user_email = var.entitled_registry_user_email
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

  # ------ DB2 -------
module "install_cp4ba"{
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/terraform-0.13/modules/cp4ba"
//  source = "../../../terraform-ibm-cloud-pak/modules/cp4ba"
    depends_on = [
    null_resource.create_DB_Schema
  ]

  CLUSTER_NAME_OR_ID      = var.cluster_id
  cluster_config_path     = data.ibm_container_cluster_config.cluster_config.config_file_path

  # ---- Platform ----
  CP4BA_PROJECT_NAME      = var.cp4ba_project_name
  USER_NAME_EMAIL         = var.entitled_registry_user_email
  ENTITLED_REGISTRY_KEY   = var.entitled_registry_key

  # ----- LDAP Settings -----
  LDAP_ADMIN_NAME         = var.ldap_admin_name
  LDAP_ADMIN_PASSWORD     = var.ldap_admin_password

  # ----- DB2 Settings -----
  DB2_PORT_NUMBER         = var.db2_port_number
  DB2_HOST_NAME           = var.db2_host_name
  DB2_HOST_IP             = var.db2_host_ip
  DB2_ADMIN_USERNAME      = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_password
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






