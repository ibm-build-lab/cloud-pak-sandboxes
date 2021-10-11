
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_name_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "entitled_registry_user_email" {
  type = string
  description = "The Entitled Registry Key's email address."
}

variable "on_vpc" {
  default = true
  description = "To determine infrastructure. Options are `true` = installs on VPC, `false`  installs on classic"
}

variable "config_dir" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "region" {
  description = "Region where the cluster is created"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}

variable "portworx_is_ready" {
  type    = any
  default = null
}

variable "entitled_registry_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "platform_version" {
  description = "Enter the platform version"
}

variable "environment" {
  default     = "dev"
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

variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "**VPC Only**: Ignored if `cluster_id` is specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`."
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
  default     = ".kube/config"
  description = "directory to store the kubeconfig file"
}

variable "registry_server" {
  description = "Enter the public image registry or route (e.g., default-route-openshift-image-registry.apps.<hostname>).\nThis is required for docker/podman login validation:"
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "cluster_name_or_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "roks_project_name" {
  default = "default"
  description = "The cluster's project name or namespace."
}

variable "cp4ba_project_name" {
  default = "cp4ba"
  description = "Project name or namespace where Cloud Pak for Business Automation will be installed."
}

variable "install_portworx" {
  type        = bool
  default     = false
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

variable "storage_capacity"{
    type = number
    default = 200
    description = "Ignored if Portworx is not enabled: Storage capacityin GBs"
}

variable "storage_profile" {
    type = string
    default = "10iops-tier"
    description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
}

variable "storage_iops" {
    type = number
    default = 10
    description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
}

variable "create_external_etcd" {
    type = bool
    default = false
    description = "Ignored if Portworx is not enabled: Do you want to create an external etcd database? `true` or `false`"
}

variable "etcd_username" {
  default = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

variable "etcd_password" {
  default = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

variable "force_delete_storage" {}

variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
}

# Password for LDAP Admin User (ldapAdminName name see below), for example passw0rd - use the password that you specified when setting up LDAP
variable "ldap_admin_password" {}

# LDAP instance access information - hostname or IP
variable "ldap_server" {}

# --------- DB2 SETTINGS ----------
locals {
  # CP4BA Database Name information
  db2_admin_user_password  = "passw0rd"
  db2_standard_license_key = "W0xpY2Vuc2VDZXJ0aWZpY2F0ZV0KQ2hlY2tTdW09Q0FBODlCOTA0QzU3RTY2OTU1RjJDQTY4MzlCRTZCOTMKVGltZVN0YW1wPTE1NjU3MjM5MDIKUGFzc3dvcmRWZXJzaW9uPTQKVmVuZG9yTmFtZT1JQk0gVG9yb250byBMYWIKVmVuZG9yUGFzc3dvcmQ9N3Y4cDRmcTJkdGZwYwpWZW5kb3JJRD01ZmJlZTBlZTZmZWIuMDIuMDkuMTUuMGYuNDguMDAuMDAuMDAKUHJvZHVjdE5hbWU9REIyIFN0YW5kYXJkIEVkaXRpb24KUHJvZHVjdElEPTE0MDUKUHJvZHVjdFZlcnNpb249MTEuNQpQcm9kdWN0UGFzc3dvcmQ9MzR2cnc1MmQyYmQyNGd0NWFmNHU4Y2M0ClByb2R1Y3RBbm5vdGF0aW9uPTEyNyAxNDMgMjU1IDI1NSA5NCAyNTUgMSAwIDAgMC0yNzsjMCAxMjggMTYgMCAwCkFkZGl0aW9uYWxMaWNlbnNlRGF0YT0KTGljZW5zZVN0eWxlPW5vZGVsb2NrZWQKTGljZW5zZVN0YXJ0RGF0ZT0wOC8xMy8yMDE5CkxpY2Vuc2VEdXJhdGlvbj02NzE2CkxpY2Vuc2VFbmREYXRlPTEyLzMxLzIwMzcKTGljZW5zZUNvdW50PTEKTXVsdGlVc2VSdWxlcz0KUmVnaXN0cmF0aW9uTGV2ZWw9MwpUcnlBbmRCdXk9Tm8KU29mdFN0b3A9Tm8KQnVuZGxlPU5vCkN1c3RvbUF0dHJpYnV0ZTE9Tm8KQ3VzdG9tQXR0cmlidXRlMj1ObwpDdXN0b21BdHRyaWJ1dGUzPU5vClN1YkNhcGFjaXR5RWxpZ2libGVQcm9kdWN0PU5vClRhcmdldFR5cGU9QU5ZClRhcmdldFR5cGVOYW1lPU9wZW4gVGFyZ2V0ClRhcmdldElEPUFOWQpFeHRlbmRlZFRhcmdldFR5cGU9CkV4dGVuZGVkVGFyZ2V0SUQ9ClNlcmlhbE51bWJlcj0KVXBncmFkZT1ObwpJbnN0YWxsUHJvZ3JhbT0KQ2FwYWNpdHlUeXBlPQpNYXhPZmZsaW5lUGVyaW9kPQpEZXJpdmVkTGljZW5zZVN0eWxlPQpEZXJpdmVkTGljZW5zZVN0YXJ0RGF0ZT0KRGVyaXZlZExpY2Vuc2VFbmREYXRlPQpEZXJpdmVkTGljZW5zZUFnZ3JlZ2F0ZUR1cmF0aW9uPQo="
  db2_admin_user_name      = "db2inst1"
  db2_project_name         = "ibm-db2"
}

locals {
  entitled_registry_key_secret_name  = "ibm-entitlement-key"
  docker_secret_name           = "docker-registry"
  docker_server                = "cp.icr.io"
  docker_username              = "cp"
  docker_password              = chomp(var.entitlement_key)
  docker_email                 = var.entitled_registry_user_email
  enable_cluster               = var.cluster_name_or_id == "" || var.cluster_name_or_id == null
  project_name                 = "cp4ba"
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
}

# -------- DB2 Variables ---------
variable "db2_admin_user_password" {
  default = "passw0rd"
}

variable "db2_admin_username" {
  default = "db2inst1"
}

variable "db2_host_name" {}

variable "db2_host_ip" {}

variable "db2_port_number" {}

# --- LDAP SETTINGS ---
locals {
  ldap_admin_name = "cn=root"
}

# --- HA Settings ---
locals {
  cp4ba_replica_count = 1
  cp4ba_bai_job_parallelism = 1
}