// Cluster Variables
variable "cluster_id" {
  default     = ""
  description = "If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

variable "entitlement" {
  default     = ""
  description = "OCP entitlement: leave blank if OCP, set it to `cloud_pak` if cloud pak entitlement"
}

variable "on_vpc" {
  type        = bool
  default     = false
  description = "Ignored if `cluster_id` is specified. Cluster type to be installed on, `true` = VPC, `false` = Classic"
}

variable "region" {
  default     = "us-south"
  description = "Ignored if `cluster_id` is specified. Region to provision the Openshift cluster. List all available regions with: `ibmcloud regions`"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "Ignored if `cluster_id` is specified. Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`"
}

variable "roks_version" {
  default     = "4.7"
  description = "Ignored if `cluster_id` is specified. List available versions: `ibmcloud ks versions`"
}

variable "project_name" {
  description = "Ignored if `cluster_id` is specified. The project_name is combined with `environment` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'project:{project_name}'"
}

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "owner" {
  description = "Ignored if `cluster_id` is specified. Use your user name or team name. The owner is used to label the cluster and other resources with the tag 'owner:{owner}'"
}

// Flavor will depend on whether classic or vpc
variable "flavors" {
  type        = list(string)
  default     = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each the workers group. Classic only takes the first flavor of the list. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider <classic | vpc-gen2>`. Classic: `[\"b3c.16x64\"]`, VPC: `[\"bx2.16x64\"]`"
}

variable "workers_count" {
  type        = list(number)
  default     = [5]
  description = "Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

// Only required if cluster id is not specified and 'on_vpc=true'
variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "**VPC Only**: Ignored if `cluster_id` is specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`."
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "Directory to store the kubeconfig file, set the value to empty string to not download the config. If running on Schematics, use `/tmp/.schematics/.kube/config`"
}


variable "datacenter" {
  default     = "dal10"
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`"
}

variable "private_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number. Leave blank if Private VLAN does not exist, one will be created"
}

variable "public_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number. Leave blank if Public VLAN does not exist, one will be created"
}

// Portworx Module Variables
variable "install_portworx" {
  type        = bool
  default     = false
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

variable "portworx_is_ready" {
  type    = any
  default = null
}

variable "ibmcloud_api_key" {
  description = "Ignored if Portworx is not enabled: IBMCloud API Key for the account the resources will be provisioned on. This is need for Portworx. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "storage_capacity" {
  type        = number
  default     = 200
  description = "Ignored if Portworx is not enabled: Storage capacityin GBs"
}

variable "storage_profile" {
  type        = string
  default     = "10iops-tier"
  description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
}

variable "storage_iops" {
  type        = number
  default     = 10
  description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
}

variable "create_external_etcd" {
  type        = bool
  default     = false
  description = "Ignored if Portworx is not enabled: Do you want to create an external etcd database? `true` or `false`"
}

# These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
# You may override these for additional security.
variable "etcd_username" {
  default     = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

variable "etcd_password" {
  default     = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

// CP4AIOPS Module Variables
variable "entitled_registry_key" {
  default     = ""
  description = "Required: Cloud Pak Entitlement Key. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable"
}

variable "entitled_registry_user_email" {
  description = "Required: Email address of the user owner of the Entitled Registry Key"
}

variable "accept_aimanager_license" {
  default = false
  type = bool
  description = "Do you accept the licensing agreement for AIManager? `T/F`"
}

variable "accept_event_manager_license" {
  default = false
  type = bool
  description = "Do you accept the licensing agreement for EventManager? `T/F`"
}

variable "namespace" {
  default = "cp4aiops"
  description = "Namespace for Cloud Pak for AIOps"
}

variable "enable_aimanager" {
  default = true
  type = bool
  description = "Install AIManager? `T/F`"
}

variable "enable_event_manager" {
  default = true
  type = bool
  description = "Install Event Manager? `T/F`"
}

#############################################
# Event Manager Options
#############################################

# PERSISTENCE
variable "enable_persistence" {
  default = true
  type = bool
  description = "Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`"
}

# INTEGRATIONS - HUMIO
variable "humio_repo" {
  default = ""
  type = string
  description = "To enable Humio search integrations, provide the Humio Repository for your Humio instance"
}

variable "humio_url" {
  default = ""
  type = string
  description = "To enable Humio search integrations, provide the Humio Base URL of your Humio instance (on-prem/cloud)"
}


# LDAP:
variable "ldap_port" {
  default = "3389"
  type = number
  description = "Configure the port of your organization's LDAP server."
}

variable "ldap_mode" {
  default = "standalone"
  type = string
  description = "Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp."
}

variable "ldap_storage_class" {
  default = ""
  type = string
  description = "LDAP Storage class - note: only needed for `standalone` mode"
}

variable "ldap_user_filter" {
  default = "uid=%s,ou=users"
  type = string
  description = "LDAP User Filter"
}

variable "ldap_bind_dn" {
  default = "cn=admin,dc=mycluster,dc=icp"
  type = string
  description = "Configure LDAP bind user identity by specifying the bind distinguished name (bind DN)."
}

variable "ldap_ssl_port" {
  default = "3636"
  type = number
  description = "Configure the SSL port of your organization's LDAP server."
}

variable "ldap_url" {
  default = "ldap://localhost:3389"
  type = string
  description = "Configure the URL of your organization's LDAP server."
}

variable "ldap_suffix" {
  default = "dc=mycluster,dc=icp"
  type = string
  description = "Configure the top entry in the LDAP directory information tree (DIT)."
}

variable "ldap_group_filter" {
  default = "cn=%s,ou=groups"
  type = string
  description = "LDAP Group Filter"
}

variable "ldap_base_dn" {
  default = "dc=mycluster,dc=icp"
  type = string
  description = "Configure the LDAP base entry by specifying the base distinguished name (DN)."
}

variable "ldap_server_type" {
  default = "CUSTOM"
  type = string
  description = "LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory"
}

# SERVICE CONTINUITY: 
variable "continuous_analytics_correlation" {
  default = false
  type = bool
  description = "Enable Continuous Analytics Correlation"
}

variable "backup_deployment" {
  default = false
  type = bool
  description = "Is this a backup deployment?"
}

# ZEN OPTIONS:
variable "zen_deploy" {
  default = false
  type = bool
  description = "Flag to deploy NOI cpd in the same namespace as aimanager"
}
variable "zen_ignore_ready" {
  default = false
  type = bool
  description = "Flag to deploy zen customization even if not in ready state"
}
variable "zen_instance_name" {
  default = "iaf-zen-cpdservice"
  type = string
  description = "Application Discovery Certificate Secret (If Application Discovery is enabled)"
}
variable "zen_instance_id" {
  default = ""
  type = string
  description = "ID of Zen Service Instance"
}
variable "zen_namespace" {
  default = ""
  type = string
  description = "Namespace of the ZenService Instance"
}
variable "zen_storage" {
  default = ""
  type = string
  description = "The Storage Class Name"
}

# TOPOLOGY OPTIONS:
# App Discovery -
variable "enable_app_discovery" {
  default = false
  type = bool
  description = "Enable Application Discovery and Application Discovery Observer"
}

variable "ap_cert_secret" {
  default = ""
  type = string
  description = "Application Discovery Certificate Secret (If Application Discovery is enabled)"
}

variable "ap_db_secret" {
  default = ""
  type = string
  description = "Application Discovery DB2 secret (If Application Discovery is enabled)"
}

variable "ap_db_host_url" {
  default = ""
  type = string
  description = "Application Discovery DB2 host to connect (If Application Discovery is enabled)"
}

variable "ap_secure_db" {
  default = false
  type = bool
  description = "Application Discovery Secure DB connection (If Application Discovery is enabled)"
}

#Network Discovery
variable "enable_network_discovery" {
  default = false
  type = bool
  description = "Enable Network Discovery and Network Discovery Observer"
}

#Observers
variable "obv_alm" {
  default = false
  type = bool
  description = "Enable ALM Topology Observer"
}

variable "obv_ansibleawx" {
  default = false
  type = bool
  description = "Enable Ansible AWX Topology Observer"
}

variable "obv_appdynamics" {
  default = false
  type = bool
  description = "Enable AppDynamics Topology Observer"
}

variable "obv_aws" {
  default = false
  type = bool
  description = "Enable AWS Topology Observer"
}

variable "obv_azure" {
  default = false
  type = bool
  description = "Enable Azure Topology Observer"
}

variable "obv_bigfixinventory" {
  default = false
  type = bool
  description = "Enable BigFixInventory Topology Observer"
}

variable "obv_cienablueplanet" {
  default = false
  type = bool
  description = "Enable CienaBluePlanet Topology Observer"
}

variable "obv_ciscoaci" {
  default = false
  type = bool
  description = "Enable CiscoAci Topology Observer"
}

variable "obv_contrail" {
  default = false
  type = bool
  description = "Enable Contrail Topology Observer"
}

variable "obv_dns" {
  default = false
  type = bool
  description = "Enable DNS Topology Observer"
}

variable "obv_docker" {
  default = false
  type = bool
  description = "Enable Docker Topology Observer"
}

variable "obv_dynatrace" {
  default = false
  type = bool
  description = "Enable Dynatrace Topology Observer"
}

variable "obv_file" {
  default = true
  type = bool
  description = "Enable File Topology Observer"
}

variable "obv_googlecloud" {
  default = false
  type = bool
  description = "Enable GoogleCloud Topology Observer"
}

variable "obv_ibmcloud" {
  default = false
  type = bool
  description = "Enable IBMCloud Topology Observer"
}

variable "obv_itnm" {
  default = false
  type = bool
  description = "Enable ITNM Topology Observer"
}

variable "obv_jenkins" {
  default = false
  type = bool
  description = "Enable Jenkins Topology Observer"
}

variable "obv_junipercso" {
  default = false
  type = bool
  description = "Enable JuniperCSO Topology Observer"
}

variable "obv_kubernetes" {
  default = true
  type = bool
  description = "Enable Kubernetes Topology Observer"
}

variable "obv_newrelic" {
  default = false
  type = bool
  description = "Enable NewRelic Topology Observer"
}

variable "obv_openstack" {
  default = false
  type = bool
  description = "Enable OpenStack Topology Observer"
}

variable "obv_rancher" {
  default = false
  type = bool
  description = "Enable Rancher Topology Observer"
}

variable "obv_rest" {
  default = true
  type = bool
  description = "Enable Rest Topology Observer"
}

variable "obv_servicenow" {
  default = true
  type = bool
  description = "Enable ServiceNow Topology Observer"
}

variable "obv_taddm" {
  default = false
  type = bool
  description = "Enable TADDM Topology Observer"
}

variable "obv_vmvcenter" {
  default = true
  type = bool
  description = "Enable VMVcenter Topology Observer"
}

variable "obv_vmwarensx" {
  default = false
  type = bool
  description = "Enable VMWareNSX Topology Observer"
}

variable "obv_zabbix" {
  default = false
  type = bool
  description = "Enable Zabbix Topology Observer"
}

# BACKUP RESTORE
variable "enable_backup_restore" {
  default = false
  type = bool
  description = "Enable Analytics Backups"
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}
