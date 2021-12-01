# Provider block
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}


# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers  = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

module "cluster" {
  source               = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks"
  enable               = local.enable_cluster
  on_vpc               = var.on_vpc

  project_name         = var.cp4ba_project_name
  owner                = var.entitled_registry_user
  environment          = var.environment

  resource_group       = var.resource_group_name
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
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_or_id
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
  KUBECONFIG = local.cluster_config_path

  # ----- Platform -----
  DB2_PROJECT_NAME        = var.db2_project_name
  DB2_ADMIN_USER_NAME     = var.db2_user
  DB2_ADMIN_USER_PASSWORD = var.db2_password

  # ------ Docker Information ----------
  ENTITLED_REGISTRY_KEY           = var.entitlement_key
  ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user
  DOCKER_SERVER                   = local.docker_server
  DOCKER_USERNAME                 = local.docker_username
}

#
module "install_cp4ba"{
    source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/terraform-0.13/examples/cp4ba"

 enable = true

  # ---- Cluster settings ----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain = var.ingress_subdomain

  # ---- Cloud Pak settings ----
  cp4ba_project_name      = "cp4ba"
  entitled_registry_user  = var.entitled_registry_user
  entitlement_key         = var.entitlement_key

  # ----- DB2 Settings -----
  db2_host_name = var.db2_host_name
  db2_host_port = var.db2_host_port
  db2_admin     = var.db2_admin
  db2_user      = var.db2_user
  db2_password  = var.db2_password

  # ----- LDAP Settings -----
  ldap_admin    = var.ldap_admin
  ldap_password = var.ldap_password
  ldap_host_ip  = var.ldap_host_ip

}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    module.install_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = local.cluster_config_path
    namespace  = var.cp4ba_project_name
  }
}






