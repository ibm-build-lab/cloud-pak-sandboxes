# Provider block
provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
}


// user output and pwd outputs

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.config_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"
  admin             = false
  network           = false
}


module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks"
//  source = "../../roks"
  // source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"
  enable = local.enable_cluster
//  on_vpc = var.on_vpc

  project_name             = var.project_name
  owner                    = var.entitled_registry_user_email
  environment              = var.environment

  resource_group       = var.resource_group
  roks_version         = var.platform_version
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter           = var.data_center
  force_delete_storage = true
  vpc_zone_names       = var.vpc_zone_names

  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
}

# getting and creation a directory for the cluster config file
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

//////######################### LDAP ##################################
module "ldap" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/ldap"
//  source = "../../ldap"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/ldap"

  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  iaas_classic_api_key  = var.iaas_classic_api_key
  iaas_classic_username = var.iaas_classic_username
  ssh_public_key_file   = var.ssh_public_key_file
  ssh_private_key_file  = var.ssh_private_key_file
  classic_datacenter    = var.classic_datacenter
}

module "cp4ba"{
    source = "git::https://github.com/jgod1360/terraform-ibm-cloud-pak/tree/cp4ba/modules/cp4ba"
//    source = "../.."
    // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
    enable = true

//    openshift_version   = var.openshift_version
//    cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_dir
//    cluster_name_id     = var.cluster_name_id
//    on_vpc              = var.on_vpc

    // IBM Cloud API Key
     CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
    //    on_vpc              = var.on_vpc

        // IBM Cloud API Key
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # Cluster
  //    on_vpc                        = var.on_vpc
  //    portworx_is_ready             = var.portworx_is_ready
  //    namespace                     = local.cp4ba_namespace
  //
  //    # Platform
      PLATFORM_SELECTED              = local.platform_options
      PLATFORM_VERSION              = local.platform_version
      PROJECT_NAME                     = local.project_name
      DEPLOYMENT_TYPE               = local.deployment_type
      USER_NAME_EMAIL                = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY               = var.entitlement_key # file("${path.cwd}/../../entitlement.key")
      # Registry Images
      DOCKER_SECRET_NAME            = var.docker_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY_PASS               = local.docker_password
      DOCKER_USER_EMAIL                  = local.docker_email
      public_registry_server        = var.public_registry_server
      LOCAL_PUBLIC_REGISTRY_SERVER   = var.public_image_registry
  //    local_registry_server         = var.registry_server
  //    local_registry_user           = var.registry_user

  //    # Storage Classes
      STORAGE_CLASSNAME            = local.storage_class_name
      SC_SLOW_FILE_STORAGE_CLASSNAME   = local.sc_slow_file_storage_classname
      SC_MEDIUM_FILE_STORAGE_CLASSNAME = local.sc_medium_file_storage_classname
      SC_FAST_FILE_STORAGE_CLASSNAME   = local.sc_fast_file_storage_classname
}

////######################### DB2 ##################################
data "external" "install_db2" {

  depends_on = [
    module.cp4ba
  ]

  program = [
    "/bin/bash", "https://github.com/jgod1360/terraform-ibm-cloud-pak/blob/cp4ba/modules/cp4ba/scripts/install_db2_local.sh"]
//    "/bin/bash", "../../scripts/install_db2_local.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace = var.namespace
  }
}


######################### PORTWORX ##################################
module "portworx" {
    depends_on = [
    module.cp4ba
  ]

  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/portworx"
//  source = "../../portworx"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/portworx"
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using with 'count'
  enable = var.install_portworx

  ibmcloud_api_key = var.ibmcloud_api_key

  // Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_dir
  worker_nodes     = var.workers_count[0]  // Number of workers

  // Storage parameters
  install_storage      = true
  storage_capacity     = var.storage_capacity  // In GBs
  storage_profile      = var.storage_profile

  // Portworx parameters
  resource_group_name   = var.resource_group
  region                = var.region
  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id             = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"

  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
  // You may override these for additional security.
  create_external_etcd  = var.create_external_etcd
  etcd_username         = var.etcd_username
  etcd_password         = var.etcd_password

  // Defaulted.  Don't change
  etcd_secret_name      = "px-etcd-certs"
}



