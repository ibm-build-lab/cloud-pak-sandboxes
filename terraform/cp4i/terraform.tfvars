// Openshift cluster parameters
// ----------------------------
ibmcloud_api_key = "wRYZPhawQp365OSPZXOgeBT8CBnf1DrllAjFH1EhbGNn"

// Use cluster_id if there is a cluster to install the Cloud Pak, example:
// cluster_id = "********************"

// Otherwise, create a cluster based on values below
project_name = "cp4i-test"
owner        = "ann"
environment  = "classic"
region       = "us-south"
resource_group = "cloud-pak-sandbox-ibm"
datacenter     = "dal12"

// VLAN's numbers on datacenter 'dal10' on Humio account. They are here until the
// permissions issues is fixed on Humio account
private_vlan_number = "3048687"
public_vlan_number  = "3048689"

// OpenShift version, run "ibmcloud ks versions" to see options
roks_version	      = 4.6

// Remove peristent storage during deletion
force_delete_storage  = true

// Classic required variables
on_vpc        	      = false

// Run "ibmcloud ks flavors --zone <zone> --provider classic"
flavors               = ["b3c.16x64"]
workers_count         = [4]

// Entitlement Key parameters
// --------------------------
// Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, save the key to the
entitled_registry_key = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1OTY4MzcwMjUsImp0aSI6IjcwMDNkYmU0ZDczZjQ4Y2M4NmQ4Y2Q5ZWE0YzVlYmY4In0.62Llbq4dGKWhPWOngqBMz5SdMZdbnGYjOFlzmN7Fgvw"
// Set the entitled_registry_user_email with the docker email address to login to the registry, example:
entitled_registry_user_email = "ann.umberhocker@ibm.com"
