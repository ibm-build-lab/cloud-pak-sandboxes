
# Table of Contents

* [What the Installer does](#Cloud-Pak-Sandbox-Installer)
* [Install with IBM Cloud Shell](#install-with-ibm-cloud-shell)
  * [Get Registry Key](#get-registry-key)
  * [Download](#download)
  * [Run Installer](#run-installer)
    * [Sample](#Sample-Output)
  * [Checking Workspaces](#checking-workspaces)
* [Install with Personal Device](#Install-with-Personal_Device)
* [Additional Information](#additional-information)
  * [RedHat OpenShift Kubernetes Service (ROKS)](#redhat-openshift-kubernetes-service)

# Cloud Pak Sandbox Installer

The Cloud Pak Sandbox Installer is an easy to use script that allows you to start up a ROKS cluster and install from a list of IBM Cloud Paks using the IBM cloud shell or your personal computer.

Currently you can run the script to install:

* Cloud Pak for Multicloud Management
* Cloud Pak for Application
* Cloud Pak for Data (under development)
* Cloud Pak for Integration (under development)

For more information view these links:
[IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)
[RedHat OpenShift Kubernetes Services/(ROCKS)](https://developer.ibm.com/recipes/tutorials/planning-redhat-openshift-deployment-on-ibm-cloud/)
[Cloud Pak for Multicloud Management](https://www.ibm.com/cloud/cloud-pak-for-management)
[Cloud Pak for Applications](https://www.ibm.com/cloud/cloud-pak-for-applications)
[Cloud Pak for Data](https://www.ibm.com/products/cloud-pak-for-data)
[Cloud Pak for Integration](https://www.ibm.com/cloud/cloud-pak-for-integration)
[IBM Cloud Shell](https://www.ibm.com/cloud/cloud-shell)

## Install with IBM Cloud Shell

[Understanding the User Interface](https://cloud.ibm.com/docs/overview?topic=overview-ui)

### Get Registry Key

First you will need your cloud pak registry key. The script will require a registry key and the email associated with the key to install any of the Cloud Paks.

If you do not have the key visit this link to generate a key:
[Generate Cloud Pak Registry Key](https://myibm.ibm.com/products-services/containerlibrary)

* For Cloud Pak for Data you will also need your docker credentials if you will be installing the Guardium External Strap module

### Download

Login into your cloud environment and click the IBM Cloud Shell in the upper right corner of IBM Cloud console

![bash-button](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/bash-symbol.png)

To use this Installer you will need to download the create-schematic.sh and the workspace-configuration-sample.json:

     git clone https://github.ibm.com/hcbt/cloud-pak-sandboxes.git

### Run Installer

To run the installer, do the following:

    cd cloud-pak-sandboxes/client-end-scripts/cp4mcm/
    chmod +x create-schematic.sh
    ./create-schematic.sh

From here the installer will ask you a set of questions pretaining to the cluster you wish to create. Here is a sample of CP4MCM output:

![script-sample](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/sample-script.png)

#### Sample Output

You can use this example, except use your registry key where requested.

    Selected: Cloud Pak for Multicloud Management
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

    To get the URL to get to the Multicloud Management Console:
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

If installing Multicloud Management you will need to get your username and password from the workspace activity plan logs. Select **Activity** from left menu.  Select **View log** link from *Plan applied** row.

Here you will find the button for the resource list (orange box), as well as the two menu locations to find the cluster (green box) when the workspace finishes, and the workspace (red box) which you can follow while the script runs.  You will need permissions to view workspace schematics.

![resource-list](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/installer/samples/resource-list.png)

The workspace will look like this, I have marked the activty button and the workspaceid. Here you can also view the variables entered when using the script:
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

Go to your working directory and follow the same instructions for running in IBM cloud bash

* [Get Registry Key](#get-registry-key)
* [Download](#download)
* [Run Installer](#run-installer)

## Additional Information

Here is some additional information pretaining to the various technologies involved with the Sandbox environment

### RedHat OpenShift Kubernetes Service (ROKS)
