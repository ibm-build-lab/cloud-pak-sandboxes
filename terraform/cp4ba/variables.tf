# --- IBM CLOUD SETTINGS ---
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


# --- ROKS SETTINGS ---
variable "roks_project" {
  default     = "cloud-pack"
  description = "Ignored if `cluster_id` is specified. The roks_name is combined with `environment` to name the cluster. The cluster name will be '{roks_name}-{environment}-cluster' and all the resources will be tagged with 'project:{roks_name}'"
}

variable "platform_version" {
  default = 4.7
  description = "The OpenShift Container Platform version"
}

variable "cluster_id" {
  default     = ""
  description = "Set your cluster ID to install the Cloud Pak for Business Automation. Leave blank to provision a new OpenShift cluster."
}

variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
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

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "owner" {
  default     = ""
  description = "Ignored if `cluster_id` is specified. Use your user name or team name. The owner is used to label the cluster and other resources with the tag 'owner:{owner}'"
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "cluster_ingress_subdomain" {
  default     = ""
  description = "The Ingress of your cluster. Ignore if there is not an existing cluster. Otherwise, for help, run the command `ibmcloud ks cluster get -c <cluster_name_or_id>` to get the Ingress Subdomain value"
}

# --- LDAP SETTINGS ---
variable "ldap_admin_name" {
  default = "cn=root"
  description = "The LDAP root administrator account to access the directory. To learn more: https://www.ibm.com/docs/en/sva/7.0.0?topic=tuning-ldap-root-administrator-account-cnroot"
}

variable "ldap_admin_password" {
  description = "LDAP Admin password"
}


variable "ldap_host_ip" {
  description = "The IP address of your LDAP."
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

# --------- DB2 SETTINGS ----------
variable "enable_db2" {
  default     = true
  description = "If set to true, it will install DB2 on the given cluster"
}

variable "enable_db2_schemas" {
  default     = true
  description = "If set to true, it will install DB2 on the given cluster"
}

 variable "db2_project_name" {
   default     = "ibm-db2"
   description = "The namespace/project for Db2"
 }

variable "db2_admin_username" {
  default     = "cpadmin"
  description = "Admin user name defined in LDAP"
}

variable "db2_user" {
  default     = "db2inst1"
  description = "User name defined in LDAP"
}

variable "db2_admin_user_password" {
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_name" {
  description = "A name you would like to attribute to your Database. i.e: sample-db2"
  default     = "sample-db2"
}

variable "db2_standard_license_key" {
  default     = ""
  description = "The standard license key for the Db2 database product. Note: the license key is required only for Advanced DB2 installation. Click here to download it: (https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/)"
}

variable "db2_operator_version" {
  default     = "db2u-operator.v1.1.11"
  description = "Operator version"
}

variable "db2_operator_channel" {
  default     = "v1.1"
  description = "The Operator Channel performs rollout update when new release is available."
}

variable "db2_instance_version" {
  default     = "11.5.7.0-cn3"
  description = "DB2 version to be installed"
}

variable "db2_cpu" {
  default     = "4"
  description = "CPU setting for the pod requests and limits"
}

variable "db2_memory" {
  default     = "16Gi"
  description = "Memory setting for the pod requests and limits"
}

variable "db2_storage_size" {
  default     = "150Gi"
  description = "Storage size for the db2 databases"
}

variable "db2_storage_class" {
  default     = "ibmc-file-gold-gid"
  description = "Name for the Storage Class"
}

locals {
  db2_pod_name     = "c-db2ucluster-db2u-0"
  db2_host_address = ""
  db2_ports        = ""
}

# --------- CP4BA SETTINGS ----------
variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "cp4ba_project_name" {
  default     = "cp4ba"
  description = "Namespace or project for cp4ba"
}


locals {
  enable_cp4ba = true
}





