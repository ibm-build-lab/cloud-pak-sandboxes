variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  default = "us-south"
  description = "Region where the cluster is created"
}

variable "resource_group" {
  default     = "default"
  description = "Resource group name where the cluster will be hosted."
}

variable "platform_version" {
  default = 4.6
  description = "The OpenShift Container Platform version"
}

variable "cluster_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Ignored if `cluster_name_or_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
}

variable "data_center" {
  default     = "dal10"
  description = "**Classic Only**. Ignored if `cluster_name_or_id` is specified. Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`"
}

variable "private_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_name_or_id` is specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number. Leave blank if Private VLAN does not exist, one will be created"
}

variable "public_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_name_or_id` is specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number. Leave blank if Public VLAN does not exist, one will be created"
}

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "on_vpc" {
  default = false
  description = "Select 'true' to install on a VPC cluster and it's using VPC Gen2. Note: CP4BA does not currently support VPC cluster."
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "entitled_registry_user" {
  type = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "cp4ba_project_name" {
  type        = string
  default     = "cp4ba"
  description = "namespace/project for cp4ba"
}

# Password for LDAP Admin User (ldapAdminName name see below), for example passw0rd - use the password that you specified when setting up LDAP
variable "ldap_admin_password" {
  description = "LDAP Admin password"
}

# LDAP instance access information - hostname or IP
variable "ldap_server" {
  description = "LDAP server "
}

# --- LDAP SETTINGS ---
locals {
  ldap_admin_name = "cn=root"
}

locals {
  enable_cluster = var.cluster_id
 }

# --------- DB2 SETTINGS ----------
variable "enable" {
  default = true
  description = "If set to true, it will install DB2 on the given cluster"
}

 variable "db2_project_name" {
   default = "ibm-db2"
   description = "The namespace/project for Db2"
 }
variable "db2_admin_password" {
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

variable "db2_standard_license_key" {
  description = "The standard license key for the Db2 database product"
}





