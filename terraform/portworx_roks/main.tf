provider "ibm" {
  generation = var.on_vpc ? 2 : 1
  region     = var.region
}

// IBM Cloud Classic

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = var.on_vpc
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  force_delete_storage = true

  // IBM Cloud Classic variables:
  datacenter          = var.on_vpc ? "" : var.datacenter

  // IBM Cloud VPC variables:
  vpc_zone_names = var.on_vpc ? var.vpc_zone_names : []

  // General IBM Cloud variables:
  workers_count       = local.workers_count
  flavors             = local.flavors
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.kubeconfig_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = local.enable_cluster ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = local.kubeconfig_dir
  download          = true
  admin             = false
  network           = false
}

module "portworx" {
  // First source is the master branch
  //source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx"

  // Testing branch
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx?ref=portworx-module"
  enable = true

  ibmcloud_api_key      = length(var.ibmcloud_api_key) > 0 ? var.ibmcloud_api_key : file(local.ibmcloud_api_key)

  // Storage parameters
  install_storage       = true
  storage_capacity      = 200
  // Portworx parameters
  resource_group_name   = var.resource_group
  dc_region             = var.region
  cluster_name          = module.cluster.name
  portworx_service_name = var.project_name
  storage_region        = var.vpc_zone_names[0]
  plan                  = "px-enterprise"   # "px-dr-enterprise", "px-enterprise"
  px_tags               = ["${var.project_name}-${var.environment}-cluster"]
  kvdb                  = "internal"   # "external", "internal"
  secret_type           = "k8s"   # "ibm-kp", "k8s"
}

module "iaf" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//iaf?ref=automate_iaf"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = var.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  cluster_name_id     = var.cluster_id

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}