provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
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
}

  
# Install ODF if the rocks version is v4.7 or newer
module "odf" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf"

  cluster = local.enable_cluster ? module.cluster.id : var.cluster_id
  ibmcloud_api_key = var.ibmcloud_api_key
  roks_version = var.roks_version

  // ODF parameters
  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  osdStorageClassName = var.osdStorageClassName
  osdSize = var.osdSize
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
}