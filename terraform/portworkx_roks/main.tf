provider "ibm" {
  generation = local.infra == "classic" ? 1 : 2
  region     = var.region
}

// IBM Cloud Classic

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = local.infra == "vpc"
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  force_delete_storage = true

  // IBM Cloud Classic variables:
  datacenter          = local.infra == "classic" ? var.datacenter : ""

  // IBM Cloud VPC variables:
  vpc_zone_names = local.infra == "vpc" ? var.vpc_zone_names : []

  // General IBM Cloud variables:
  workers_count       = local.workers_count
  flavors             = local.flavors
}

module "portworx" {
  // First source is the master branch
  //source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx"

  // Testing branch
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx?ref=portworx-module"
  enable = true
  // Storage parameters
  install_storage      = true
  storage_capacity     = 200
  // Portworx parameters
  resource_group_name  = var.resource_group
  dc_region            = var.region
  cluster_name         = "${var.project_name}-${var.environment}-cluster"  # Name format copied from the 'classic.tf' and 'vpc.tf'
  portworx_service_name = "${var.project_name}"
  storage_region       = var.vpc_zone_names
  plan                 = "px-enterprise"   # "px-dr-enterprise", "px-enterprise"
  px_tags              = ["${var.project_name}-${var.environment}-cluster"]
  kvdb                 = "internal"   # "external", "internal"
  secret_type          = "k8s"   # "ibm-kp", "k8s"
}