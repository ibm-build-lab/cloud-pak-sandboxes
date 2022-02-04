# Cloud Pak Sandboxes

This project contains assets to create and manage Cloud Pak Sandboxes on IBM Cloud Classic.

## Installer

The [installer/](./cloud-pak-installer) directory contains a bash script for the users to install any Cloud Pak on IBM Cloud Classic. This script can be run either from an IBM Cloud Shell window, or locally on your machine if you have all the requirements.

The bash script and support files interact with the Schematics service on IBM Public Cloud using the Terraform scripts located in the [terraform/](./terraform) directory.

## Scripts

The [scripts/](./scripts) directory contain additional scripts created to do installations and support the sandbox environment. They are created for the developers and the Sandbox administrators.

## Terraform

The [terraform/](./terraform) directory has all the Terraform code that use [these](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak) modules to install multiple Cloud Paks on an OpenShift cluster on IBM Cloud Classic. This directory is only for developers or advance users that would like to execute the code locally or remotely using IBM Cloud Schematics, either for development, testing or get a custom Cloud Pak in an advance way. The code can be executed using `make` with a set of Makefiles.
