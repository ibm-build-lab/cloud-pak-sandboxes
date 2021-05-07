variable "enable_cluster" {
  default     = true
  description = "Flag setup to install a ROKS cluster. `true` or `false`"
}

variable "on_vpc" {
  description = "Create Openshift cluster on IBM Cloud classic or VPC-gen2. Enter 'false' or 'true'"
}

variable "install_portworx" {
  default     = true
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

variable "region" {
  default     = "us-south"
  description = "Region to provision the Openshift cluster. List all available regions with: ibmcloud regions"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API Key for the account the resources will be provisioned on. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "project_name" {
  description = "The project_name is combined with environment to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'project:{project_name}'"
}

variable "owner" {
  description = "Use your user name or team name. The owner is used to label the cluster and other resources with the tag 'owner:{owner}'"
}

variable "environment" {
  default     = "dev"
  description = "The environment is combined with project_name to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "Resource Group in your account to host the cluster. List all available resource groups with: ibmcloud resource groups"
}

variable "cluster_id" {
  description = "If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

variable "datacenter" {
  default     = ""
  description = "Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: ibmcloud ks zone ls --provider classic"
}

variable "vpc_zone_names" {
  default     = ["us-south-1"]
  description = "Zone in the IBM Cloud VPC region to provision the cluster. List all available zones with: ibmcloud ks zone ls --provider vpc-gen2"
}

// VLAN's numbers variables on the datacenter, they are here until the
// permissions issues is fixed on Humio account
variable "private_vlan_number" {
  default     = ""
  description = "Private VLAN assigned to your zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number"
}

variable "public_vlan_number" {
  default     = ""
  description = "Public VLAN assigned to your zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number"
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

// ROKS Module : Local Variables and constansts

locals {
  flavors                    = ["bx2.16x64"]
  workers_count              = [4]
  roks_version               = "4.6"
  kubeconfig_dir             = "./.kube/config"
  ibmcloud_api_key           = "./ibmcloud.key"
}