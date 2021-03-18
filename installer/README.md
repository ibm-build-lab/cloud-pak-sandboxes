# Cloud Pak Sandbox User Installation Script

- [Cloud Pak Sandbox User Installation Script](#cloud-pak-sandbox-user-installation-script)
  - [Introduction](#introduction)
  - [Install with IBM Cloud Shell](#install-with-ibm-cloud-shell)
    - [Get Registry Key](#get-registry-key)
    - [Download the Script](#download-the-script)
    - [Run Installer](#run-installer)
  - [Install From Personal Device](#install-from-personal-device)
  - [VLAN Usage](#vlan-usage)
  - [Checking Progress](#checking-progress)
  - [Deleting the Workspace and Resources](#deleting-the-workspace-and-resources)
  - [Additional Information](#additional-information)

## Introduction

The Cloud Pak Sandbox Installer is an easy to use script that allows you to provision a ROKS cluster and install from a list of IBM Cloud Paks using the IBM Cloud Shell or your personal computer. This script creates a Schematics workspace that then executes Terraform scripts to create the necessary resources.

Currently you can run the script to install:

- Cloud Pak for Multi Cloud Management
- Cloud Pak for Application
- Cloud Pak for Data
- Cloud Pak for Integration
- Cloud Pak for Automation (under development)
- WatsonAIOps (under development)

## Install Using IBM Cloud Shell

[Understanding the IBM Cloud User Interface](https://cloud.ibm.com/docs/overview?topic=overview-ui)

### Get registry key

Each Cloud Pak requires an entitlement key. The script will prompt for this key and the email associated with it to install any of the Cloud Paks.

If you do not have the key visit this link to generate one:
[Generate Cloud Pak Entitlement Key](https://myibm.ibm.com/products-services/containerlibrary)

NOTE: For Cloud Pak for Data you will also need your docker credentials if installing the Guardium External Strap module

### Download the script

Log in to your [IBM Cloud](http://cloud.ibm.com) account and click the terminal icon in the upper right corner of IBM Cloud console to open the **IBM Cloud Shell** 

![bash-button](./images/bash-symbol.png)
Within the **IBM Cloud Shell** terminal, clone the following repo:

     git clone https://github.com/ibm-hcbt/cloud-pak-sandboxes

### Run installer

To run the installer, do the following in the **IBM Cloud Shell** terminal:

    cd cloud-pak-sandboxes/installer
    chmod +x create-schematic.sh
    ./create-schematic.sh

From here the Installer will ask you a set of questions pertaining to the cluster you wish to create. 

Here is a sample of CP4MCM output:

![script-sample](./images/sample-script.png)

## Install From Personal Device

To run this Installer on your local machine:

1. Ensure that [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) is installed
   
2. Ensure that the [IBM Schematics Plug-in](https://cloud.ibm.com/docs/schematics?topic=schematics-setup-cli) is installed
   
   `ibmcloud plugin install schematics`
3. Log into the ibm cloud 
   
   `ibmcloud login -sso`
4. Ensure that you are in the desired account and resource group 
   
   `ibmcloud target`

5. Go to your working directory and follow the same instructions for running in IBM Cloud Shell:

- [Get Registry Key](#get-registry-key)
- [Download the Script](#download-the-script)
- [Run Installer](#run-installer)

## VLAN Usage

In order for the Installer to create a ROKS cluster there must be a public and private VLAN available to the Datacenters you plan to build to.  No worries if you do not know how to manage VLANS becuase the installer script will handle that for you.  

While running the installer you will be prompted for region and datacenter. Once selected the installer will automatically check available VLANs for use.  If there are not existing VLANS, script will prompt to create them.

Finally, once a VLAN is created it will take some time until it is ready for use. This time varies based of the availablity of resources at the datacenter and can take anywhere from a few seconds to several minutes.

## Checking Progress

To check the status of the workspace:

### 1. Log in to [IBM Cloud](http://cloud.ibm.com) account
### 2. Select "Schematics workspaces" from the resource menu on top left column of IBM Cloud Console

The image below shows the button for the resource list (orange box), as well as the two menu locations to find the cluster (green box) when the workspace finishes, and the workspace (red box) which you can follow while the script runs. 

NOTE: User may need permissions to view workspace schematics. Contact account administrator if restricted.

![resource-list](./images/resource-list.png)

### 3. Click to open your workspace
All workspaces and clusters made with this tool will end in "-sandbox"

The workspace will look like this. The "activity" button and the "workspaceid" are marked. You can also view the variables entered when using the script:
![sample1](./images/activity-location.png)

Within the **Schematic workspace** select **Activity** from left menu. Select **View log** link from **Plan applied** row, as shown in the image below:

![sample2](./images/activity-log.png)
**NOTE:** the workspace activity plan logs will print out the Cloud Pak console *url*, *username* and *password* once the installation is complete. Once the cloud pak has been installed and the admin/password credentials are provided, please change the password immediately.  

## Deleting The Workspace and Resources

### 1. Log in to your [IBM Cloud](http://cloud.ibm.com) account
### 2. Select "Schematics workspaces" from the resource menu on top left column of IBM Cloud Console

The image below shows the button for the resource list (orange box), as well as the two menu locations to find the cluster (green box) when the workspace finishes, and the workspace (red box) which you can follow while the script runs. 

NOTE: You will need permissions to view workspace schematics.

![resource-list](./images/resource-list.png)

### 3. Click "Delete" from the 3 dot menu on the right of your workspace
All workspaces and clusters made with this tool will end in "-sandbox"

Select `Delete workspace` and `Delete all associated resources` options, type the name of the workspace and select `Delete`.  This should issue a "terraform destroy" command to delete all resources that were created by the "terraform apply".  

**NOTE:** If the workspace fails to delete, the Terraform state is out of sync.  Attempt deletion again but only select `Delete workspace` option.  Resources may then need to be manually deleted.

## Additional Information

Here is some additional documentation pertaining to the various technologies involved with the Sandbox environment

Cloud Pak Sandbox Installer [README](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/README.md) (this document)

Cloud Pak Sandbox environment [Terraform modules](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak)

Cloud Pak Sandbox environment [Terraform scripts](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform)

Cloud Pak for Applications [Documentation](https://www.ibm.com/cloud/cloud-pak-for-applications) 

Cloud Pak for Applications [Sandbox Inputs/Outputs and Validation](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4app/README.md) 

Cloud Pak for Data [Documentation](https://www.ibm.com/products/cloud-pak-for-data) 

Cloud Pak for Data [Sandbox Inputs/Outputs and Validation](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4data/README.md) 

Cloud Pak for Integration [Documentation](https://www.ibm.com/cloud/cloud-pak-for-integration) 

Cloud Pak for Integration [Sandbox Inputs/Outputs and Validation](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4int/README.md) 

Cloud Pak for Multi Cloud Management [Documentation](https://www.ibm.com/cloud/cloud-pak-for-management) 

Cloud Pak for Multi Cloud Management [Sandbox Inputs/Outputs and Validation](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4mcm/README.md) 

[IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)

[IBM Cloud Shell](https://www.ibm.com/cloud/cloud-shell)

[IBM Cloud Console](https://cloud.ibm.com/docs/overview?topic=overview-ui)

[IBM Schematic Workspaces](http://github.com)

[RedHat OpenShift Kubernetes Services/(ROKS)](https://developer.ibm.com/recipes/tutorials/planning-redhat-openshift-deployment-on-ibm-cloud/)

