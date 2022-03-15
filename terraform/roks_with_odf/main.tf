provider "ibm" {
  region           = var.region
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  // General
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment
  resource_group = var.resource_group
  roks_version   = var.roks_version
  entitlement    = var.entitlement
  force_delete_storage = var.force_delete_storage

  // Parameters for the Workers
  flavors        = var.flavors
  workers_count  = var.workers_count
  // Classic only
  datacenter     = var.datacenter
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
  // VPC only
  vpc_zone_names = var.vpc_zone_names

  // Parameters for Kubernetes Config
  // download_config = length(var.config_dir) > 0
  // config_dir      = var.config_dir
  // config_admin    = false
  // config_network  = false
  
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${var.config_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]

  cluster_name_id   = local.enable_cluster ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = var.config_dir
  download          = true
  admin             = false
  network           = false
}

# Install ODF if the rocks version is v4.7 or newer
module "odf" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf"

  count = var.is_enable ? 1 : 0
  cluster = var.cluster_id
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
}