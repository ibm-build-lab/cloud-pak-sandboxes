# Provider block
terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version    = "~> 1.12"
    }
  }
}

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.config_dir}"
  }
}

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  project_name             = var.cp4ba_project_name
  owner                    = var.entitled_registry_user_email
  environment              = var.environment

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
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"
  admin             = false
  network           = false
}

# --------------- PROVISION DB2  ------------------
module "install_db2" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/blob/main/modules/Db2"

  # ----- Cluster -----
  KUBECONFIG = var.cluster_config_path

  # ----- Platform -----
  DB2_PROJECT_NAME        = var.db2_project_name
  DB2_ADMIN_USER_NAME     = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_user_password

  # ------ Docker Information ----------
  ENTITLED_REGISTRY_KEY           = var.entitlement_key
  ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
  DOCKER_SERVER                   = local.docker_server
  DOCKER_USERNAME                 = local.docker_username
}

#
module "install_cp4ba"{
    source = "git::https://github.com/jgod1360/terraform-ibm-cloud-pak/tree/cp4ba/modules/cp4ba"

  CLUSTER_NAME_OR_ID     = var.cluster_id

  # ---- IBM Cloud API Key ----
  IBMCLOUD_API_KEY = var.ibmcloud_api_key

  # ---- Platform ----
  CP4BA_PROJECT_NAME            = var.cp4ba_project_name
  USER_NAME_EMAIL               = var.entitled_registry_user_email
  ENTITLED_REGISTRY_KEY         = var.entitlement_key

  # ---- Registry Images ----
  ENTITLED_REGISTRY_KEY_SECRET_NAME = local.entitled_registry_key_secret_name
  DOCKER_SERVER                 = local.docker_server
  DOCKER_USERNAME               = local.docker_username
  DOCKER_USER_EMAIL             = local.docker_email

  # ----- DB2 Settings -----
  DB2_PORT_NUMBER         = var.db2_port_number
  DB2_HOST_NAME           = var.db2_host_name
  DB2_HOST_IP             = var.db2_host_ip
  DB2_ADMIN_USERNAME      = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_user_password

  # ----- LDAP Settings -----
  LDAP_ADMIN_NAME         = local.ldap_admin_name
  LDAP_ADMIN_PASSWORD     = var.ldap_admin_password
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    module.install_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.cp4ba_project_name
  }
}






