# IBM Automation Foundation Parameters and Installation Validation

## Cloud Pak Entitlement Key

This Cloud Pak requires an Entitlement Key. It can be retrieved from https://myibm.ibm.com/products-services/containerlibrary.

Edit the `./my_variables.auto.tfvars` file to define the `entitled_registry_user_email` variable and optionally the variable `entitled_registry_key` or save the entitlement key in the file `entitlement.key`. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key.

For example:

```hcl
entitled_registry_user_email = "john.smith@ibm.com"

# Optionally:
entitled_registry_key        = "< Your Entitled Key here >"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Input Parameters

Besides the access credentials the Terraform code requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

| Name                           | Description | Default             | Required |
| ------------------------------ | ------ | ------------------- | -------- |
| `entitled_registry_key`        | Required: Entitlement key from - https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable or save the key to the file `entitlement.key`.  |                     | Yes       |
| `entitled_registry_user_email` | Optional: Email address of the user owner of the Entitled Registry Key  |                     | No      |
| `ic_api_key` | Required: API Key needed to log in to IBM Cloud  |                     | Yes      |
| `region`                       | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`   | `us-south`          | Yes       |
| `resource_group`               | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups` | `cloud-pak-sandbox` | No       |
| `cluster_id`                   | Optional: If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned   | No       |
| `on_vpc`                   | Whether OpenShift cluster is on VPC  | false                    | No       |
| `project_name`                 | Only required if cluster_id is not specified. The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources  | `cloud-pack`        | Yes      |
| `environment`                  | Only required if cluster_id is not specified. The environment name is used to label the cluster and other resources | `sandbox`           | No       |
| `owner`                        | Optionl: user name or team name. Used to label the cluster and other resources | `anonymous`         | Yes      |
| `flavors`        | Only required if cluster_id is not specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: "ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2" or "ibmcloud ks flavors --zone dal10 --provider classic". On Classic it is only possible to have one worker group, so only list one flavor, i.e. ["b3c.16x64"]. Example on VPC ["mx2.4x32", "mx2.8x64", "cx2.4x8"] or ["mx2.4x32"]   | ["b3c.16x64"]                    | No       |
| `datacenter`                   | Classic Only: Only required if cluster_id is not specified. Datacenter or zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`   | `dal10`             | No       |
| `private_vlan_number`          | Classic Only: Only required if cluster_id is not specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |                     | No       |
| `public_vlan_number`           | Classic Only: Only required if cluster_id is not specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.   |                     | No       |
| `vpc_zone_names`                   | VPC Only: Only required if cluster_id is not specified. Zones in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`   | `us-south-1`             | No       |

If you are using Schematics directly or the Private Catalog, set the variable `entitled_registry_key` with the content of the Entitlement Key, the file `entitlement.key` is not available.

## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`       | The unique identifier of the cluster.                                                                                               |
| `cluster_name`     | The cluster name which should be: `{project_name}-{environment}-cluster`                                                            |
| `resource_group`   | Resource group where the OpenShift cluster is created                                                                               |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |                                                                                        |
| `iaf_namespace` | Kubernetes namespace where all the iaf resources are installed                                                                     |

## Validations

If you have not setup `kubectl` to access the cluster, execute:

```bash
# If created with Terraform:
ibmcloud ks cluster config --cluster $(terraform output cluster_id)

# If created with Schematics:
ibmcloud ks cluster config --cluster $(ibmcloud schematics workspace output --id $WORKSPACE_ID --json | jq -r '.[].output_values[].cluster_id.value')

# If created with IBM Cloud CLI:
ibmcloud ks cluster config --cluster $CLUSTER_NAME
```

Verify the cluster is up and running executing these commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

Execute the following commands to validate this Cloud Pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output iaf_namespace)

# All resources
kubectl get all --namespace $(terraform output iaf_namespace)
```

## Uninstall

To uninstall IAF and its dependencies from a cluster, execute the following commands:

```bash
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com opencloud-operators
kubectl delete -n iaf subscription.operators.coreos.com ibm-automation
kubectl delete -n openshift-operators operatorgroup.operators.coreos.com iaf-group
kubectl delete namespace iaf
```

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
