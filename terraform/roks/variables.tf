variable "on_vpc" {
  type        = bool
  default     = false
  description = "To determine infrastructure. Options are `true` = installs on VPC, `false` installs on classic"
}

variable "install_portworx" {
  default     = false
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API Key for the account the resources will be provisioned on. This is need for Portworx. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "entitlement" {
  default     = ""
  description = "OCP entitlement. Enter 'cloud_pak' if using a Cloud Pak entitlement.  Leave blank if OCP entitlement"
}

variable "region" {
  default     = "us-south"
  description = "List all available regions with: ibmcloud regions"
}

variable "project_name" {
  default     = "roks"
  description = "The project name is used to name the cluster with the environment name"
}

variable "owner" {
  default     = "anonymous"
  description = "User name or team name. The owner is used to label the cluster and other resources"
}

variable "environment" {
  default     = "dev"
  description = "The environment name is used to name the cluster with the project name"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "List all available resource groups with: ibmcloud resource groups"
}

variable "roks_version" {
  default     = "4.6"
  description = "List available versions: ibmcloud ks versions"
}

variable "force_delete_storage" {
  type        = bool
  default     = true
  description = "If set to true, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is false"
}

variable "cluster_id" {
  description = "If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Array with the flavors or machine types of each of the workers. List all flavors for each zone with: ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2 or ibmcloud ks flavors --zone dal10 --provider classic. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. Example on VPC `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"mx2.4x32\"]`"
}

variable "workers_count" {
  type    = list(number)
  default = [4]
  description = "Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]"
}

variable "private_vlan_number" {
  default     = ""
  description = "Classic Only. Private VLAN assigned to zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number"
}

variable "public_vlan_number" {
  default     = ""
  description = "Classic Only. Public VLAN assigned to zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number"
}

variable "datacenter" {
  default = "dal12"
  description = "Classic Only. List all available datacenters/zones with: 'ibmcloud ks zone ls --provider classic'"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["us-south-1"]
  description = "VPC only. Array with the subzones in the region to create the workers groups. List all the zones with: 'ibmcloud ks zone ls --provider vpc-gen2'. Example [\"us-south-1\", \"us-south-2\", \"us-south-3\"]"
}

variable "config_dir" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file, set the value to empty string to not download the config"
}

// Portworx Variables

variable "install_storage" {
    default     = true
    description = "If set to false does not install storage and attach the volumes to the worker nodes. Enabled by default"
}

variable "create_external_etcd" {
    type = bool
    default = false
    description = "Do you want to create an external_etcd? `True` or `False`"
}

variable "storage_capacity"{
    type = number
    default = 200
    description = "Storage capacity in GBs"
}

variable "storage_iops" {
    type = number
    default = 10
    description = "This is used only if a user provides a custom storage_profile"
}

variable "storage_profile" {
    type = string
    default = "10iops-tier"
    description = "The is the storage profile used for creating storage"
}

variable "unique_id" {
    description = "Unique string for naming resources"
    default     = "px-roks"
}

# These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
# You may override these for additional security.
variable "etcd_username" {
  default = ""
  description = "etcd username"
}
variable "etcd_password" {
  default = ""
  description = "etcd password"
}
variable "etcd_secret_name" {
  default = "px-etcd-certs" # don't change this
  description = "etcd secret name. Default: `px-etcd-certs` (Don't change this)"
}

