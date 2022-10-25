# Provider block
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}


module "create_cluster" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  // General
  project_name         = var.project_name
  owner                = var.owner
  environment          = var.environment
  resource_group       = var.resource_group
  roks_version         = var.roks_version
  entitlement          = var.entitlement
  force_delete_storage = true

  // Parameters for the Workers
  flavors       = var.flavors
  workers_count = var.workers_count
  // Classic only
  datacenter          = var.datacenter
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
  // VPC only
  vpc_zone_names = var.vpc_zone_names
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = local.enable_cluster ? module.create_cluster.id : var.cluster_id
  resource_group_id = module.create_cluster.resource_group.id
  config_dir        = var.cluster_config_path
  download          = true
  admin             = false
  network           = false
}

module "install_portworx" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/portworx"
  enable = var.install_portworx
  ibmcloud_api_key = var.ibmcloud_api_key
  # Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  worker_nodes     = var.workers_count[0]
  # Storage parameters
  install_storage       = true
  storage_capacity      = var.storage_capacity
  storage_iops          = var.storage_iops
  storage_profile       = var.storage_profile
  # Portworx parameters
  resource_group_name   = var.resource_group
  region                = var.region
  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id             = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"
  create_external_etcd  = var.create_external_etcd
  etcd_username         = var.etcd_username
  etcd_password         = var.etcd_password
  etcd_secret_name      = "px-etcd-certs"
}

resource "null_resource" "cluster_wait" {
  depends_on = [
    module.create_cluster,
    module.install_portworx
  ]
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "sleep 300"
  }
}

module "install_cp4aiops" {
  depends_on = [null_resource.cluster_wait]
  source              = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4aiops"
  enable              = true
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = module.install_portworx.portworx_is_ready

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  accept_aimanager_license     = var.accept_aimanager_license
  accept_event_manager_license = var.accept_event_manager_license
  namespace            = var.namespace
  enable_aimanager     = true

  //************************************
  // EVENT MANAGER OPTIONS START *******
  //************************************
  enable_event_manager = true

  // Persistence option
  enable_persistence               = var.enable_persistence

  // Integrations - humio
  humio_repo                       = var.humio_repo
  humio_url                        = var.humio_url

  // LDAP options
  ldap_port                        = var.ldap_port
  ldap_mode                        = var.ldap_mode
  ldap_user_filter                 = var.ldap_user_filter
  ldap_bind_dn                     = var.ldap_bind_dn
  ldap_ssl_port                    = var.ldap_ssl_port
  ldap_url                         = var.ldap_url
  ldap_suffix                      = var.ldap_suffix
  ldap_group_filter                = var.ldap_group_filter
  ldap_base_dn                     = var.ldap_base_dn
  ldap_server_type                 = var.ldap_server_type

  // Service Continuity
  continuous_analytics_correlation = var.continuous_analytics_correlation
  backup_deployment                = var.backup_deployment

  // Zen Options
  zen_deploy                       = var.zen_deploy
  zen_ignore_ready                 = var.zen_ignore_ready
  zen_instance_name                = var.zen_instance_name
  zen_instance_id                  = var.zen_instance_id
  zen_namespace                    = var.zen_namespace
  zen_storage                      = var.zen_storage

  // TOPOLOGY OPTIONS:
  // App Discovery -
  enable_app_discovery             = var.enable_app_discovery
  ap_cert_secret                   = var.ap_cert_secret
  ap_db_secret                     = var.ap_db_secret
  ap_db_host_url                   = var.ap_db_host_url
  ap_secure_db                     = var.ap_secure_db
  // Network Discovery
  enable_network_discovery         = var.enable_network_discovery
  // Observers
  obv_docker                       = var.obv_docker
  obv_taddm                        = var.obv_taddm
  obv_servicenow                   = var.obv_servicenow
  obv_ibmcloud                     = var.obv_ibmcloud
  obv_alm                          = var.obv_alm
  obv_contrail                     = var.obv_contrail
  obv_cienablueplanet              = var.obv_cienablueplanet
  obv_kubernetes                   = var.obv_kubernetes
  obv_bigfixinventory              = var.obv_bigfixinventory
  obv_junipercso                   = var.obv_junipercso
  obv_dns                          = var.obv_dns
  obv_itnm                         = var.obv_itnm
  obv_ansibleawx                   = var.obv_ansibleawx
  obv_ciscoaci                     = var.obv_ciscoaci
  obv_azure                        = var.obv_azure
  obv_rancher                      = var.obv_rancher
  obv_newrelic                     = var.obv_newrelic
  obv_vmvcenter                    = var.obv_vmvcenter
  obv_rest                         = var.obv_rest
  obv_appdynamics                  = var.obv_appdynamics
  obv_jenkins                      = var.obv_jenkins
  obv_zabbix                       = var.obv_zabbix
  obv_file                         = var.obv_file
  obv_googlecloud                  = var.obv_googlecloud
  obv_dynatrace                    = var.obv_dynatrace
  obv_aws                          = var.obv_aws
  obv_openstack                    = var.obv_openstack
  obv_vmwarensx                    = var.obv_vmwarensx

  // Backup Restore
  enable_backup_restore            = var.enable_backup_restore

  //************************************
  // EVENT MANAGER OPTIONS END *******
  //************************************
}
