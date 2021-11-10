# Provider block
provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
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
  DB2_PROJECT_NAME        = local.db2_project_name
  DB2_ADMIN_USER_NAME     = var.db2_admin_username
  DB2_ADMIN_USER_PASSWORD = var.db2_admin_user_password

  # ------ Docker Information ----------
  ENTITLED_REGISTRY_KEY           = var.entitlement_key
  ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
  DOCKER_SERVER                   = local.docker_server
  DOCKER_USERNAME                 = local.docker_username
}

//module "portworx" {
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/portworx"
//  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
//  enable = var.install_portworx
//
//  ibmcloud_api_key = var.ibmcloud_api_key
//
//  // Cluster parameters
//  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
//  worker_nodes     = var.workers_count[0]  // Number of workers
//
//  // Storage parameters
//  install_storage      = true
//  storage_capacity     = var.storage_capacity  // In GBs
//  storage_iops         = var.storage_iops   // Must be a number, it will not be used unless a storage_profile is set to a custom profile
//  storage_profile      = var.storage_profile
//
//  // Portworx parameters
//  resource_group_name   = var.resource_group
//  region                = var.region
//  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
//  unique_id             = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"
//
//  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
//  // You may override these for additional security.
//  create_external_etcd  = var.create_external_etcd
//  etcd_username         = var.etcd_username
//  etcd_password         = var.etcd_password
//
//  // Defaulted.  Don't change
//  etcd_secret_name      = "px-etcd-certs"
//}

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






