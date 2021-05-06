# IBM ROKS and Portworx Parameters and Installation Validation

## IBM Cloud API Key

This Cloud Pak requires an [IBM Cloud API key](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform#create-an-ibm-cloud-api-key)

If running locally, edit the `./my_variables.auto.tfvars` file to define the `ic_api_key`.
For example:

```hcl
# Required
ic_api_key = "< your IBM Cloud API key >"

```

## Input Parameters

Besides the access credentials the Terraform code requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

| Name                           | Description | Default             | Required |
| ------------------------------ | ------ | ------------------- | -------- |
| `ibmcloud_api_key` | Required: API Key needed to log in to IBM Cloud  |                     | Yes      |
| `region`                       | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`   | `us-south`          | Yes       |
| `resource_group`               | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups` | `cloud-pak-sandbox` | No       |
| `cluster_id`                   | Optional: If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned   | | No       |
| `on_vpc`                   | Whether OpenShift cluster is on VPC  | `false`                    | Yes       |
| `project_name`                 | Only required if cluster_id is not specified. The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources  | `cloud-pack`        | No      |
| `environment`                  | Only required if cluster_id is not specified. The environment name is used to label the cluster and other resources | `sandbox`           | No       |
| `owner`                        | Optional: user name or team name. Used to label the cluster and other resources | `anonymous`         | No      |
| `flavors`        | Only required if cluster_id is not specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: "ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2" or "ibmcloud ks flavors --zone dal10 --provider classic". On Classic it is only possible to have one worker group, so only list one flavor, i.e. ["b3c.16x64"]. Example on VPC ["mx2.4x32", "mx2.8x64", "cx2.4x8"] or ["mx2.4x32"]   | `["b3c.16x64"]`                  | No       |
| `datacenter`                   | Classic Only: Only required if cluster_id is not specified. Datacenter or zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`   | `dal10`             | No       |
| `private_vlan_number`          | Classic Only: Only required if cluster_id is not specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |                     | No       |
| `public_vlan_number`           | Classic Only: Only required if cluster_id is not specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.   |                     | No       |
| `vpc_zone_names`                   | VPC Only: Only required if cluster_id is not specified. Zones in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`   | `us-south-1`             | No       |
| `enable`                       | If set to `false` does not install Portworx on the given cluster. Enabled by default | `true`  | Yes       |
| `kube_config_path`             | This is the path to the kube config                                          |  `.kube/config` | Yes       |
| `install_storage`              | If set to `false` does not install storage and attach the volumes to the worker nodes. Enabled by default  |  `true` | Yes      |
| `storage_capacity`             | Sets the capacity of the volume in GBs. |   `200`    | Yes      |
| `storage_iops`                 | Sets the number of iops for a custom class. *Note* This is used only if a user provides a custom `storage_profile` |   `10`    | Yes      |
| `storage_profile`              | The is the storage profile used for creating storage. If this is set to a custom profile, you must update the `storage_iops` |   `10iops-tier`    | Yes      |
| `resource_group`          | The resource group name where the cluster is housed                                  |         | Yes      |
| `cluster_id`                   | The name of the cluster created |  | Yes       |
| `create_external_etcd`         | Set this value to `true` or `false` to create an external etcd | `false` | Yes |
| `etcd_username`                | Username needed for etcd                         |      | yes |
| `etcd_password`                | Password needed for etcd                         |      | Yes |
| `etcd_secret_name`             | Etcd secret name, do not change it from default  | `px-etcd-certs`    | Yes |

## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`       | The unique identifier of the cluster.                                                                                               |
| `cluster_name`     | The cluster name which should be: `{project_name}-{environment}-cluster`                                                            |
| `cluster_vlan_number` | Private and Public vlan for classic clusters | |
| `cluster_config` | Cluster config of the ROKS cluster |
| `resource_group`   | Resource group where the OpenShift cluster is created                                                                               |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |                                                                                        |


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
```

For more information on Portworx Validation, go [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/portworx/testing#3-verify).

## Uninstall

To uninstall Portworx and its dependencies from a cluster, execute the following commands:

While logged into the cluster

```bash
curl -fsL https://install.portworx.com/px-wipe | bash
```
This will remove the Portworx and Stork pods on the cluster.

Once this completes, execute: `terraform destroy` if this was create locally using Terraform or remove the Schematic's workspace.
