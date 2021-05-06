variable "on_vpc" {
  type        = bool
  default     = false
  description = "To determine infrastructure. Options are `true` = installs on VPC, `false`  installs on classic"
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


