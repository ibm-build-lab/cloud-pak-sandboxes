# Cloud Pak Sandbox Private Catalog

This Private Catalog creates an Openshift (ROKS) cluster on IBM Cloud Classic or VPC Gen 2 with Cloud Pak for Multi-Cloud-Management or for Applications or both.

Follow these instruction to open the Private Catalog:

1. Open the IBM Cloud Console, go to **Catalog** and select **Cloud-Pak Cluster Sandbox**
2. Select the tile **ROKS**
3. Select the **Resource Group** to create the cluster, for example: `cloud-pak-sandbox`. Assign the same value to **resource_group** in the section **Parameters with default values**
4. In the section **Parameters without default values**, assign values to: **owner**, **project_name**. These parameters are used to identify your cluster. Use your name or team name and what project that will be using this cluster.
5. In the section **Parameters with default values**, validate the value of the OpenShift version to install. Execute in a terminal `ibmcloud ks versions` to list all the available versions.
6. In the same section, assign or verify the value of the parameter **region**. In a terminal, execute `ibmcloud is regions` to select a valid region.
7. In the same section, select a value for the parameter **infra**. select either `classic` or `vpc`, depending of where you would like the cluster.
8. If the cluster will be created on **IBM Cloud Classic** (`infra` = `classic`), assign or verify the following parameters in the section **Parameters without default values**:
   1. Verify or change the value of **datacenter**. In a terminal, execute: `ibmcloud ks zone ls --provider classic` to list all the available options.
   2. Verify or change the parameter **size** with the number of workers in the cluster. Also, verify or change the parameter **flavor** with the machine type of the workers. Execute in a terminal `ibmcloud ks flavors --zone <ZONE>` to know the available machine type in the selected zone (replace `<ZONE>` with the selected zone). For example, in the zone `dal10`, one of the available flavors is `b3c.4x16`.
   3. The values of the parameters listed in the following step (#9) are ignored, you can have any value there.
9. If the cluster will be created on **IBM Cloud VPC** (`infra` = `vpc`), assign or verify the following parameters in the section **Parameters without default values**:
   1. Verify or change the value of **vpc_zone_names_list**. In a terminal, execute: `ibmcloud ks zone ls --provider vpc-gen2` to list all the available sub-zones in the selected region on step #6, for example: `us-south-1`. On IBM Cloud VPC can be created multiple worker pools on different sub-zones, separate the multiple sub-zones with a coma, like so: `us-south-1, us-south-2, us-south-3`
   2. Verify or change the value of **flavors_list**. In the terminal, execute `ibmcloud ks flavors --zone <ZONE> --provider vpc-gen2` for each selected zones in the step 9.1, for example: `mx2.4x32` if the zone is `us-south-1`. If you choose multiple zones make sure the amount of flavors is the same, for example if 3 zones where selected the flavors could be: `mx2.4x32, mx2.8x64, cx2.4x8`.
   3. Verify or change the value of **workers_count_list** with the number of workers per sub-zone, they cannot be less than 2 per zone. For example, if you choose one zone the value can be: `2`, if the amount of zones is 3 the value can be: `2,3,2`.
   4. The values of the parameters listed in the previous step (#8) are ignored, you can have any value there.
10. Click on the button **Install**, in a few seconds you'll see the logs from the Schematics workspace with the creation of the cluster.
