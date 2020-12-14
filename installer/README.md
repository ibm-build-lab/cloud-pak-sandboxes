# Cloud Pak Sandbox User Installation Script

- [Cloud Pak Sandbox User Installation Script](#cloud-pak-sandbox-user-installation-script)
  - [What does this installer do?](#what-does-this-installer-do)
  - [Install with IBM Cloud Shell](#install-with-ibm-cloud-shell)
    - [Get Registry Key](#get-registry-key)
    - [Download](#download)
    - [Run Installer](#run-installer)
      - [Sample Output](#sample-output)
    - [Checking your Workspace](#checking-your-workspace)
  - [Install with Personal Device (for advanced users)](#install-with-personal-device-for-advanced-users)
  - [Additional Information](#additional-information)

## What does this installer do?

The Cloud Pak Sandbox Installer is an easy to use script that allows you to provision a ROKS cluster and install from a list of IBM Cloud Paks using the IBM Cloud Shell or your personal computer. This script creates a Schematics workspace that then executes Terraform scripts to create the necessary resources.

Currently you can run the script to install:

- Cloud Pak for Multi Cloud Management
- Cloud Pak for Application
- Cloud Pak for Data (under development)
- Cloud Pak for Integration (under development)

## Install with IBM Cloud Shell

[Understanding the IBM Cloud User Interface](https://cloud.ibm.com/docs/overview?topic=overview-ui)

### Get Registry Key

Each Cloud Pak requires an entitlement key. The script will prompt for this key and the email associated with it to install any of the Cloud Paks.

If you do not have the key visit this link to generate one:
[Generate Cloud Pak Entitlement Key](https://myibm.ibm.com/products-services/containerlibrary)

- For Cloud Pak for Data you will also need your docker credentials if you will be installing the Guardium External Strap module

### Download

Log into your cloud environment and click the IBM Cloud Shell in the upper right corner of IBM Cloud console

![bash-button](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/bash-symbol.png)

To use this Installer you will need to download the `create-schematic.sh` and the `workspace-configuration-sample.json`:

     git clone https://github.com/ibm-hcbt/cloud-pak-sandboxes

### Run Installer

To run the installer, do the following:

    cd cloud-pak-sandboxes/installer
    chmod +x create-schematic.sh
    ./create-schematic.sh

From here the Installer will ask you a set of questions pertaining to the cluster you wish to create. Here is a sample of CP4MCM output:

![script-sample](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/sample-script.png)

#### Sample Output

You can use this example, except use your registry key where requested.

    Selected: Cloud Pak for Multi Cloud Management
    Enter sandbox name (sandbox name will be appended with -mcm-sandbox): jah-demo7
    Enter Project Owner Name: jah
    Enter Environment Name: mcm
    Enter Project Name (new clusters will be named starting with Project Name): jah-demo7
    Enter Entitled Registry key (retrieve from https://myibm.ibm.com/products-services/containerlibrary):
    Enter Entitled Registry Email: johnnie.hernandez@ibm.com
    Enter Cluster ID (Leave blank for new clusters):
    Install Infrastructure Management Module? Y/y for yes: n
    Install Monitoring Module? Y/y for yes: n
    Install Security Services Module? Y/y for yes: n
    Install Operations Module? Y/y for yes: n
    Install Tech Preview Module? Y/y for yes: n
    Choose your cluster region:
    1) us-east
    2) us-south
    3) eu-central
    4) uk-south
    5) ap-north
    6) ap-south
    #? 2
    Chosen region: us-south, pease pick a data center:
    1) dal10
    2) dal12
    3) dal13
    #? 3
    Chosen data center: dal13

    Creating workspace: jah-demo7-mcm-sandbox...


    Created workspace: jah-demo7-mcm-sandbox-8a7cc386-b604-41
    To view workspace, login to cloud.ibm.com and go to: https://cloud.ibm.com/schematics/workspaces/jah-demo7-mcm-sandbox-8a7cc386-b604-41
    Working on setting up workspace....
    \
    Workspace ready
    Generating workspace plan:

    Activity ID   9ef43d9194249ddd857828c9f82a2a19

    OK
    Schematics plan in progress...
    -ready
    Preparing to apply jah-demo7-mcm-sandbox

    Activity ID   b57854a70490ff5657ddfc148517edc9

    OK
    Applied jah-demo7-mcm-sandbox
    To see progress, login to cloud.ibm.com and go to: https://cloud.ibm.com/schematics/workspaces/jah-demo7-mcm-sandbox-8a7cc386-b604-41
    Once there click 'Activity' on the left, then select View Log from the 'Applying Plan' activity
    For MCM installs the credentials can be retrieved from the 'Plan applied' log
    MCM will take approximately 40 minutes for software to install. The time is currently
    Fri Dec  4 10:13:50 EST 2020

    To monitor progress: 'kubectl get pods -A | grep -Ev "Completed|1/1|2/2|3/3|4/4|5/5|6/6|7/7"'
    Should not return anything when MCM is up and running

    To get the URL to get to the Multi Cloud Management Console:
    ibmcloud oc cluster config -c  --admin
    kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo

    To get default login id:
    kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -d && echo

    To get default Password:
    kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo

### Checking your Workspace

To check your workspace:

1. Log in to your IBM Cloud account
2. Select **Schematics workspaces** from the resource menu on top left column of IBM Cloud Console
3. Click to open your workspace. All workspaces and clusters made with this script will end in "-sandbox"

If installing Multi Cloud Management you will need to get your username and password from the workspace activity plan logs. Select **Activity** from left menu. Select **View log** link from \*Plan applied\*\* row.

Here you will find the button for the resource list (orange box), as well as the two menu locations to find the cluster (green box) when the workspace finishes, and the workspace (red box) which you can follow while the script runs. You will need permissions to view workspace schematics.

![resource-list](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/resource-list.png)

The workspace will look like this, I have marked the activity button and the workspaceid. Here you can also view the variables entered when using the script:
![sample1](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/activity-location.png)

To go from the workspace homepage to the activity logs click here, from here you can view the activity logs. For mcm users you will need to view the apply logs to get credentials.
![sample2](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/activity-log.png)

For more info about sandboxes and workspaces you can view these links
[Resource List](https://cloud.ibm.com/docs/overview?topic=overview-ui)
[Schematic Workspaces](http://github.com)

## Install with Personal Device (for advanced users)

To use this Installer you will need to download and install IBM Cloud CLI then download the create-schematic.sh and workspace-configuration-sample.json

You can follow this link for more instructions:
[IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)

You will also need to install the "schematics" plug-in
[IBM Schematics Plug-in](https://cloud.ibm.com/docs/schematics?topic=schematics-setup-cli)

Go to your working directory and follow the same instructions for running in IBM Cloud Shell

- [Get Registry Key](#get-registry-key)
- [Download](#download)
- [Run Installer](#run-installer)

## Additional Information

Here is some additional documentation pertaining to the various technologies involved with the Sandbox environment

[Cloud Pak for Applications](https://www.ibm.com/cloud/cloud-pak-for-applications) Documentation

[Cloud Pak for Applications](./terraform/cp4app/README.md) Sandbox Inputs/Outputs and Validation

[Cloud Pak for Data](https://www.ibm.com/products/cloud-pak-for-data) Documentation

[Cloud Pak for Data](./terraform/cp4data/README.md) Sandbox Inputs/Outputs and Validation

[Cloud Pak for Integration](https://www.ibm.com/cloud/cloud-pak-for-integration) Documentation

[Cloud Pak for Integration](./terraform/cp4int/README.md) Sandbox Inputs/Outputs and Validation

[Cloud Pak for Multi Cloud Management](https://www.ibm.com/cloud/cloud-pak-for-management) Documentation

[Cloud Pak for Multi Cloud Management](./terraform/cp4mcm/README.md) Sandbox Inputs/Outputs and Validation

[Terraform modules for the Cloud Pak Sandbox environment](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak)

[IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)

[RedHat OpenShift Kubernetes Services/(ROCKS)](https://developer.ibm.com/recipes/tutorials/planning-redhat-openshift-deployment-on-ibm-cloud/)

[IBM Cloud Shell](https://www.ibm.com/cloud/cloud-shell)
