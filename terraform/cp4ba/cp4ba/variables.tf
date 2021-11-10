variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "entitled_registry_user_email" {
  type = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "config_dir" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "region" {
  default = "us-south"
  description = "Region where the cluster is created"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}

variable "entitled_registry_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "cp4ba_project_name" {
  type        = string
  default     = "cp4ba"
  description = "namespace/project for cp4ba"
}

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "on_vpc" {
  default = false
  description = "Select 'true' to install on a VPC cluster and it's using VPC Gen2. Note: CP4BA does not currently support VPC cluster."
}

variable "platform_version" {
  default = 4.6
  description = ""
}
variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

variable "data_center" {
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

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "registry_server" {
  description = "Enter the public image registry or route (e.g., default-route-openshift-image-registry.apps.<hostname>).\nThis is required for docker/podman login validation:"
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "registry_user" {
  description = "Enter the user name for your docker registry: "
}

variable "docker_password" {
  description = "Enter the password for your docker registry: "
}

variable "docker_username" {
  description = "Docker username for creating the secret."
}

variable "docker_secret_name" {
  description = "Enter the name of the docker registry's image."
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
}

variable "enable" {
  default = true
  description = "If set to true installs Cloud-Pak for Integration on the given cluster"
}

# Password for LDAP Admin User (ldapAdminName name see below), for example passw0rd - use the password that you specified when setting up LDAP
variable "ldap_admin_password" {
  description = "LDAP Admin password"
}

# LDAP instance access information - hostname or IP
variable "ldap_server" {
  description = "LDAP server "
}

# --------- DB2 SETTINGS ----------
locals {
  db2_project_name              = "ibm-db2"
}

locals {
  docker_secret_name           = "docker-registry"
  docker_server                = "cp.icr.io"
  docker_username              = "cp"
  docker_password              = chomp(var.entitlement_key)
  docker_email                 = var.entitled_registry_user_email
  enable_cluster               = var.cluster_id == "" || var.cluster_id == null
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
 }

locals {
  storage_class_name               = "cp4a-file-retain-gold-gid"
}


# -------- DB2 Variables ---------
variable "db2_admin_user_password" {
  default = "passw0rd"
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_admin_username" {
  default = "db2inst1"
  description = "Db2 admin username defined in LDAP"
}

variable "db2_host_name" {
  description = "Host name of Db2 instance"
}

variable "db2_host_ip" {
  description = "IP address for the Db2"
}

variable "db2_port_number" {
  description = "Port for Db2 instance"
}

locals {
  entitled_registry_key_secret_name  = "ibm-entitlement-key"
  docker_server                = "cp.icr.io"
  docker_username              = "cp"
  docker_email                 = var.entitled_registry_user_email
  enable_cluster               = var.cluster_id == "" || var.cluster_id == null
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
}

# --- LDAP SETTINGS ---
locals {
  ldap_admin_name = "cn=root"
}

# --- HA Settings ---
locals {
  cp4ba_replica_count = 1
  cp4ba_bai_job_parallelism = 1
}


//variable "storage_capacity"{
//    type = number
//    default = 200
//    description = "Ignored if Portworx is not enabled: Storage capacityin GBs"
//}
//
//variable "storage_profile" {
//    type = string
//    default = "10iops-tier"
//    description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
//}
//
//variable "storage_iops" {
//    type = number
//    default = 10
//    description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
//}
//
//variable "create_external_etcd" {
//    type = bool
//    default = false
//    description = "Ignored if Portworx is not enabled: Do you want to create an external etcd database? `true` or `false`"
//}
//
//# These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
//# You may override these for additional security.
//variable "etcd_username" {
//  default = ""
//  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
//}
//
//variable "etcd_password" {
//  default = ""
//  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
//}

//variable "vpc_zone_names" {
//  type        = list(string)
//  default     = ["us-south-1"]
//  description = "**VPC Only**: Ignored if `cluster_id` is specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`."
//}

//variable "storage_capacity"{
//    type = number
//    default = 200
//    description = "Ignored if Portworx is not enabled: Storage capacity in GBs"
//}
//
//variable "storage_db2" {
//    type = number
//    default = 10
//    description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
//}
//
//variable "storage_profile" {
//    type = string
//    default = "10iops-tier"
//    description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
//}
//
//variable "create_external_etcd" {
//    type = bool
//    default = false
//    description = "Ignored if Portworx is not enabled: Do you want to create an external etcd database? `true` or `false`"
//}
//
//# These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
//# You may override these for additional security.
//variable "etcd_username" {
//  default = ""
//  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
//}
//
//variable "etcd_password" {
//  default = ""
//  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
//}

// Portworx Module Variables
//variable "install_portworx" {
//  type        = bool
//  default     = false
//  description = "Install Portworx on the ROKS cluster. `true` or `false`"
//}

//# --- LDAP SETTINGS ---
//locals {
//  # LDAP name - don't use dashes (-), only use underscores
//  ldap_name = "ldap_custom"
//  ldap_admin_name = "cn=root"
//  ldap_type = "IBM Security Directory Server"
//  ldap_port = "389"
//  ldap_server = "150.238.92.26"
//  ldap_base_dn = "dc=example,dc=com"
//  ldap_user_name_attribute = "*:cn"
//  ldap_user_display_name_attr = "cn"
//  ldap_group_base_dn = "dc=example,dc=com"
//  ldap_group_name_attribute = "*:cn"
//  ldap_group_display_name_attr = "cn"
//  ldap_group_membership_search_filter = "('\\|(\\&(objectclass=groupOfNames)(member={0}))(\\&(objectclass=groupOfUniqueNames)(uniqueMember={0})))"
//  ldap_group_member_id_map = "groupofnames:member"
//  ldap_ad_gc_host = ""
//  ldap_ad_gc_port = ""
//  ldap_ad_user_filter = "(\\&(samAccountName=%v)(objectClass=user))"
//  ldap_ad_group_filter = "(\\&(samAccountName=%v)(objectclass=group))"
//  ldap_tds_user_filter = "(\\&(cn=%v)(objectclass=person))"
//  ldap_tds_group_filter = "(\\&(cn=%v)(\\|(objectclass=groupofnames)(objectclass=groupofuniquenames)(objectclass=groupofurls)))"
//}
