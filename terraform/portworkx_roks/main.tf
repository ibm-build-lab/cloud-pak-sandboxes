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


// TO_DO

//module "portworks" {
# NUM_WORKERS= var.workers_count
# IAM_TOKEN=
# RESOURCE_GROUP= var.resource_group
# VPC_REGION= local.infra == "classic" ? var.datacenter : var.vpc_zone_names
# CLUSTER= 
# REGION= var.region
# STORAGE_CAPACITY= 
//}