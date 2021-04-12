provider "ibm" {
  generation = 2
  region     = "us-south"
}

// IBM Cloud Classic

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = "false"
  project_name   = "roks"
  owner          = "johandry"
  environment    = "test"

  // Openshift parameters:
  resource_group       = "default"
  roks_version         = "4.6"
  force_delete_storage = true

  // IBM Cloud Classic variables:
  datacenter          = "dal10"
  workers_count       = [1]
  flavors             = ["b3c.4x16"]
}

// IBM Cloud VPC Gen 2

module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = "true"
  project_name   = "roks"
  owner          = "johandry"
  environment    = "test"

  // Openshift parameters:
  resource_group       = "default"
  roks_version         = "4.6"
  force_delete_storage = true

  // IBM Cloud VPC variables:
  vpc_zone_names = ["us-south-1"]
  flavors        = ["mx2.4x32"]
  workers_count  = [2]
}

// TO_DO

//module "portworks" {
//  
//}