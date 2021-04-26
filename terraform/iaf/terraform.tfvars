// Openshift cluster parameters
// ----------------------------

// Optional: Use cluster_id if there is a cluster to install the Cloud Pak, example:
// cluster_id = "****************"
// RECOMMENDED: to set the cluster_id using an external input, like this:
// export TF_VAR_cluster_id="****************"

// Required: indicate what type of cluster IAF will be installed on, 'true' = VPC, 'false' = Classic.
on_vpc       = false

// Otherwise, create a cluster based on values below
project_name = "iaf"
// Optional: set the project_name variable to avoid conflicts, like this:
// export TF_VAR_project_name="something-different"
owner        = "anonymous"
// Optional: set the owner variable from $USER, like this:
// export TF_VAR_owner=$USER
environment  = "sandbox"
region       = "us-south"
// Using development resource group on cloud account:
// resource_group = "cloud-pak-sandbox-ibm"
// Using a standard partner account resource group
resource_group = "cloud-pak-sandbox"
datacenter     = ""

// VLAN's numbers from desired "datacenter".  Run command "ibmcloud ks vlan ls --zone" to find.  If they don't exists, TF will create them
private_vlan_number = ""
public_vlan_number  = ""


// Entitlement Key parameters
// --------------------------

// 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, save the key to the
// file "./entitlement.key"
// 2. Set the entitled_registry_user_email with the docker email address to login to the registry, example:
// entitled_registry_user_email = "John.Doe@ibm.com"

// RECOMMENDED: to set the entitled_registry_user_email using an external input, like this:
// export TF_VAR_entitled_registry_user_email="John.Doe@ibm.com"

