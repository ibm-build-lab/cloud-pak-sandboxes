###################### CLOUD ######################
ibmcloud_api_key      = "********************"
iaas_classic_api_key  = "********************"
iaas_classic_username = "joe@ibm.com"
resource_group        = "cloud-pak-sandbox-ibm"
region                = "us-south"


###################### LDAP ######################
os_reference_code     = "CentOS_8_64"
datacenter            = "dal12"
hostname              = "ldapvm"
ibmcloud_domain       = "ibm.cloud"
cores                 = 2
memory                = 4096
disks                 = [25]
hourly_billing        = true
local_disk            = true
private_network_only  = false
ldapBindDN            = "cn=root"
ldap_admin_password   = "********************"


###################### CLUSTER ######################




###################### DB2 ######################
db2_admin_username       = "db2inst1"
db2_admin_user_password  = "********************"
db2_host_address         = "********************"
db2_ports                = "********************"
db2_standard_license_key = ""


###################### CP4BA ######################
entitled_registry_user_email = "joe@ibm.com"
entitled_registry_key        = "********************"


