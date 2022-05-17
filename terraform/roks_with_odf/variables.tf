
variable "cluster_id" {
  default     = ""
  description = "If you have an existing cluster, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

variable "entitlement" {
  default     = "cloud_pak"
  description = "Ignored if `cluster_id` is specified. Enter 'cloud_pak' if using a Cloud Pak entitlement.  Leave blank if OCP entitlement"
}

variable "on_vpc" {
  type        = bool
  default     = true
  description = "Ignored if `cluster_id` is specified. Type of infrastructure should cluster be? Options are `true` = VPC, `false` classic"
}

variable "region" {
  default     =  "ca-tor" //"us-south"
  description = "Region that the cluster is/will be located. List all available regions with: `ibmcloud regions`"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "Resource group that the cluster is/will be located. List all available resource groups with: `ibmcloud resource groups`"
}

variable "roks_version" {
  default     = "4.7"
  type = string
  description = "Ignored if `cluster_id` is specified. List available versions: `ibmcloud ks versions`"
}

variable "project_name" {
  default     = "roks"
  description = "Ignored if `cluster_id` is specified. The project name is used to name the cluster with the environment name"
}

variable "owner" {
  default     = "anonymous"
  description = "Optional. User name or team name. The owner is used to label the cluster and other resources"
}

variable "environment" {
  default     = "test"
  description = "Ignored if `cluster_id` is specified.  The environment name is used to name the cluster with the project name"
}

variable "force_delete_storage" {
  type        = bool
  default     = true
  description = "Ignored if `cluster_id` is specified. If set to true, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is false"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["bx2.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
}

variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Array with the amount of workers on each workers group. Classic set up only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

variable "private_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Private VLAN assigned to zone. List available VLANs in the zone: `ibmcloud target <resource_group>; ibmcloud ks vlan ls --zone <zone>`"
}

variable "public_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Public VLAN assigned to zone. List available VLANs in the zone: `ibmcloud target <resource_group>; ibmcloud ks vlan ls --zone <zone>`"
}

variable "datacenter" {
  default = "dal12"
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Classic Only. List all available datacenters/zones with: `ibmcloud ks zone ls --provider classic`"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["ca-tor-1"]  //["us-south-1"]
  description = "**VPC only**. Ignored if `cluster_id` is specified. Array with the subzones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example [\"us-south-1\", \"us-south-2\", \"us-south-3\"]"
}

// ODF Variables

variable "ibmcloud_api_key" {
  default = ""
  description = "Ignored if not installing ODF. IBMCloud API Key for the account the resources will be provisioned on. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "osdStorageClassName" {
  description = "Storage class that you want to use for your OSD devices"
  type = string
  default = "ibmc-vpc-block-10iops-tier"
}

variable "osdSize" {
  description = "Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd."
  type = string
  default = "100Gi"
}

variable "numOfOsd" {
  description = "Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value."
  default = 1
}

variable "billingType" {
  description = "Billing Type for your ODF deployment (`essentials` or `advanced`)."
  type = string
  default = "advanced"
}

variable "ocsUpgrade" {
  description = "Whether to upgrade the major version of your ODF deployment."
  type = bool
  default = false
}

variable "clusterEncryption" {
  description = "Enable encryption of storage cluster"
  type = bool
  default = false
}

# Options required for Openshift 4.7 only
variable "monSize" {
  description = "Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each"
  type = string
  default = "20Gi"
}

variable "monStorageClassName" {
  description = "Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class"
  type = string
  default = "ibmc-vpc-block-10iops-tier"
}
