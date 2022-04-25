//  source = "../../../terraform-ibm-cloud-pak/modules/roks"
###################### CLOUD ######################
ibmcloud_api_key      = "2lT1xRhO_PSfohImF4sB02IrlTXFltwYjfjtxihqqrsK"
iaas_classic_username = "2129514_joel.goddot@ibm.com"
resource_group        = "cloud-pak-sandbox-ibm"
region                = "us-south"

###################### LDAP ######################
datacenter            = "dal12"
hostname              = "ldapvm"
ibmcloud_domain       = "ibm.cloud"
cores                 = 2
memory                = 4096
disks                 = [25]
hourly_billing        = true
local_disk            = true
private_network_only  = false

###################### ROKS ######################
on_vpc             = false
entitlement        = "cloud_pak"
project_name       = "joel"
roks_project       = "joel-cp4ba-sndbx"
owner              = "joel"
environment        = "local-1"
private_vlan_number = "2138"
public_vlan_number = "959"
data_center        = "dal12"
cluster_id         = "c9cqlb3d0bbgkrbogim0"

###################### DB2 ######################
enable_db2         = false
enable_db2_schema  = true
db2_admin          = "cpadmin"
db2_user           = "db2inst1"
db2_admin_user_password  = "Passw0rd"
db2_admin_username       = "db2inst1"
//db2_host_address         = ""
//db2_ports            = ""
db2_standard_license_key = ""
db2_operator_version          = "db2u-operator.v1.1.10"

###################### CP4BA ######################
entitled_registry_user_email = "joel.goddot@ibm.com"
entitled_registry_key     = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2NTA4MjQxNzAsImp0aSI6IjBhYTYwNDAzZWQxODQ0NGVhYzJhOWVkMzdkNWMwZTFiIn0.XElaKUi3OjUHQtQinh1iUM5iklQ3ouhn2KLc91cUPW0"
ldap_admin = "cn=root"
ldap_server = ""
ldap_admin_password = "Passw0rd"
ldap_host_ip = "50.22.130.123"
