provider "ibm" {
  # generation = local.infra == "classic" ? 1 : 2
  region = var.region
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  // General parameters:
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  flavors              = var.flavors
  workers_count        = local.workers_count
  datacenter           = var.datacenter
  force_delete_storage = true
  vpc_zone_names       = var.vpc_zone_names

  // Kubernetes Config parameters:
  // download_config = false
  // config_dir      = var.kubeconfig_dir
  // config_admin    = false
  // config_network  = false

  // Debugging
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${var.kubeconfig_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]

  cluster_name_id   = local.enable_cluster ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = var.kubeconfig_dir
  download          = true
  admin             = false
  network           = false
}

module "cp4s" {
  // source = "../../../../ibm-build-lab/terraform-ibm-cloud-pak/cp4data"
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4s"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email

  admin_user = var.admin_user
}
