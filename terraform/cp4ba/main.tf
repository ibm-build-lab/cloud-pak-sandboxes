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

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks"
  enable               = local.enable_cluster
  on_vpc               = var.on_vpc
  owner                = var.entitled_registry_user
  environment          = var.environment
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
  cluster_name_or_id   = var.cluster_name_or_id
  resource_group_id    = data.ibm_resource_group.group.id
  download             = true
  config_dir           = var.cluster_config_path
  admin                = false
  network              = false
}

# --------------- PROVISION DB2  ------------------
module "install_db2" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/blob/main/modules/Db2"

  # ----- Cluster -----
  KUBECONFIG = var.cluster_config_path

  # ----- Platform -----
  DB2_PROJECT_NAME        = var.db2_project_name
  DB2_ADMIN_USER_NAME     = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_password

  # ------ Docker Information ----------
  ENTITLED_REGISTRY_KEY           = var.entitlement_key
  ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user
}

  # ------ D
module "install_cp4ba"{
  source = "git::https://github.com/jgod1360/terraform-ibm-cloud-pak/tree/cp4ba/modules/cp4ba"

  CLUSTER_NAME_OR_ID      = var.cluster_name_or_id
  cluster_config_path     = data.ibm_container_cluster_config.cluster_config.config_file_path

  # ---- Platform ----
  CP4BA_PROJECT_NAME      = var.cp4ba_project_name
  USER_NAME_EMAIL         = var.entitled_registry_user
  ENTITLED_REGISTRY_KEY   = var.entitlement_key

  # ----- LDAP Settings -----
  LDAP_ADMIN_NAME         = local.ldap_admin_name
  LDAP_ADMIN_PASSWORD     = var.ldap_admin_password

  # ----- DB2 Settings -----
  DB2_PORT_NUMBER         = var.db2_port_number
  DB2_HOST_NAME           = var.db2_host_name
  DB2_HOST_IP             = var.db2_host_ip
  DB2_ADMIN_USERNAME      = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_password
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    module.install_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig     = var.cluster_config_path
    namespace      = var.cp4ba_project_name
  }
}






