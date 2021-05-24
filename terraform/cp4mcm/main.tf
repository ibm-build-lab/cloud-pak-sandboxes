provider "ibm" {
  region     = var.region
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  // source = "../../../../ibm-hcbt/terraform-ibm-cloud-pak/roks"
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"
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
  vpc_zone_names       = var.vpc_zone_names
  force_delete_storage = true

  // Kubernetes Config parameters:
  // download_config = false
  // config_dir      = local.kubeconfig_dir
  // config_admin    = false
  // config_network  = false

  // Debugging
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
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
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx"
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
  enable = var.install_portworx

  ibmcloud_api_key = var.ibmcloud_api_key

  // Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  worker_nodes     = var.workers_count[0]  // Number of workers

  // Storage parameters
  install_storage      = true
  storage_capacity     = var.storage_capacity  // In GBs
  storage_iops         = var.storage_iops   // Must be a number, it will not be used unless a storage_profile is set to a custom profile
  storage_profile      = var.storage_profile

  // Portworx parameters
  resource_group_name   = var.resource_group
  region                = var.region
  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id             = "px-roks"

  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
  // You may override these for additional security.
  create_external_etcd  = var.create_external_etcd
  etcd_username         = var.etcd_username
  etcd_password         = var.etcd_password

  // Defaulted.  Do not change
  etcd_secret_name      = "px-etcd-certs"
}

// TODO: With Terraform 0.13 replace the parameter 'enable' with 'count'
module "cp4mcm" {
  // source = "../../../../ibm-hcbt/terraform-ibm-cloud-pak/cp4mcm"
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm"
  enable = true
  on_vpc = var.on_vpc
  //roks_is_ready = module.cluster.endpoint

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
    
  // Was Portworx installed? If so, will need to wait until it is finished
  portworx_is_ready = var.install_portworx ? module.portworx.portworx_is_ready : "true"

  // Entitled Registry parameters:
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email

  install_infr_mgt_module      = var.install_infr_mgt_module
  install_monitoring_module    = var.install_monitoring_module
  install_security_svcs_module = var.install_security_svcs_module
  install_operations_module    = var.install_operations_module
  install_tech_prev_module     = var.install_tech_prev_module
}
