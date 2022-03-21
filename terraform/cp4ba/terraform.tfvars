###################### CLOUD ######################
ibmcloud_api_key      = "******************"
iaas_classic_username = "******************"
resource_group        = "******************"
region                = "******************"

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
on_vpc              = false
entitlement         = "cloud_pak"
project_name        = "******************"
roks_project        = "******************"
owner               = "******************"
environment         = "******************"
private_vlan_number = "******************"
public_vlan_number  = "******************"
data_center         = "******************"

###################### DB2 ######################
db2_user                 = "db2inst1"
db2_admin_user_password  = "******************"
db2_admin_username       = "******************"
db2_host_address         = ""
db2_host_port            = ""
db2_standard_license_key = ""
operatorVersion          = "db2u-operator.v1.1.10"

###################### CP4BA ######################
entitled_registry_key        = "******************"
entitled_registry_user_email = "******************"
ldap_admin                   = "cn=root"
ldap_server                  = ""
ldap_admin_password          = "******************"
ldap_host_ip                 = "******************"



