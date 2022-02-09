# Provider block
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
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
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"
  enable               = local.enable_cluster
  on_vpc               = var.on_vpc
  project_name         = var.project_name
  environment          = var.environment
  owner                = var.owner
  resource_group       = var.resource_group
  roks_version         = var.roks_version
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter           = var.datacenter
  force_delete_storage = true
  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = local.enable_cluster ? module.create_cluster.id : var.cluster_id
  resource_group_id = module.create_cluster.resource_group.id
  config_dir        = var.cluster_config_path
  download          = true
  admin             = false
  network           = false
}

module "install_portworx" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/portworx"
  enable = var.install_portworx
  ibmcloud_api_key = var.ibmcloud_api_key
  # Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  worker_nodes     = var.workers_count[0]
  # Storage parameters
  install_storage       = true
  storage_capacity      = var.storage_capacity
  storage_iops          = var.storage_iops
  storage_profile       = var.storage_profile
  # Portworx parameters
  resource_group_name   = var.resource_group
  region                = var.region
  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id             = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"
  create_external_etcd  = var.create_external_etcd
  etcd_username         = var.etcd_username
  etcd_password         = var.etcd_password
  etcd_secret_name      = "px-etcd-certs"
}

module "install_cp4aiops" {
    source              = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4aiops"
    enable              = true
    on_vpc              = var.on_vpc
    portworx_is_ready   = module.install_portworx.portworx_is_ready
    // ROKS cluster parameters:
    cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
    // Entitled Registry parameters:
    entitled_registry_key        = var.entitled_registry_key
    entitled_registry_user_email = var.entitled_registry_user_email
    namespace                    = var.namespace

}
