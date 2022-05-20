provider "ibm" {
  version    = "~> 1.34"
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
  project_name         = var.project_name
  owner                = var.owner
  environment          = var.environment
  resource_group       = var.resource_group
  roks_version         = var.roks_version
  entitlement          = var.entitlement
  force_delete_storage = var.force_delete_storage

  // Parameters for the Workers
  flavors       = var.flavors
  workers_count = var.workers_count
  // Classic only
  datacenter          = var.datacenter
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

module "portworx" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/portworx"
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
  enable = var.install_portworx

  ibmcloud_api_key = var.ibmcloud_api_key

  // Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  worker_nodes     = var.workers_count[0] // Number of workers

  // Storage parameters
  install_storage  = true
  storage_capacity = var.storage_capacity // In GBs
  storage_iops     = var.storage_iops     // Must be a number, it will not be used unless a storage_profile is set to a custom profile
  storage_profile  = var.storage_profile

  // Portworx parameters
  resource_group_name = var.resource_group
  region              = var.region
  cluster_id          = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id           = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"

  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
  // You may override these for additional security.
  create_external_etcd = var.create_external_etcd
  etcd_username        = var.etcd_username
  etcd_password        = var.etcd_password

  // Defaulted.  Don't change
  etcd_secret_name = "px-etcd-certs"
}

// Module:
module "odf" {
  source = "./../../modules/odf"
  cluster = var.cluster
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

module "cp4data" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4data_4.0"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = var.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = module.portworx.portworx_is_ready // only need if on_vpc = true

  // Prereqs
  worker_node_flavor = var.flavors[0]

  operator_namespace = var.operator_namespace

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = var.cpd_project_name

  // IBM Cloud API Key
  ibmcloud_api_key = var.ibmcloud_api_key

  region              = var.region
  resource_group_name = var.resource_group
  cluster_id          = local.enable_cluster ? module.cluster.id : var.cluster_id

  // Parameters to install submodules
  install_wsl         = var.install_wsl
  install_aiopenscale = var.install_aiopenscale
  install_wml         = var.install_wml
  install_wkc         = var.install_wkc
  install_dv          = var.install_dv
  install_spss        = var.install_spss
  install_cde         = var.install_cde
  install_spark       = var.install_spark
  install_dods        = var.install_dods
  install_ca          = var.install_ca
  install_ds          = var.install_ds
  install_db2oltp     = var.install_db2oltp
  install_db2wh       = var.install_db2wh
  install_big_sql     = var.install_big_sql
  install_wsruntime   = var.install_wsruntime
}
