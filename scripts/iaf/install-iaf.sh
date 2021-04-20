#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************
# Download and install a few CLI tools and the Kubernetes Service plug-in.
#   curl -sL https://ibm.biz/idt-installer | bash

# Log in to IBM Cloud
#ibmcloud login -sso
echo "What Resource Group is your OpenShift Cluster in (ibmcloud resource groups)?"
read RESOURCE_GROUP
ibmcloud target -g $RESOURCE_GROUP

source ./iafenv.config
ibmcloud oc cluster config -c $CLUSTER --admin

# create namespace to install IAF
kubectl create namespace $IAF_PROJECT
kubectl config set-context --current --namespace=$IAF_PROJECT

# Create the Operator catalog source
kubectl apply -f ./resources.yaml

sleep 60
oc get catalogsource -n openshift-marketplace | grep IBM
oc get pods -n openshift-marketplace | grep opencloud-operators
oc get pods -n openshift-marketplace | grep ibm-operator

echo "Installing..."
kubectl apply -f ./installation.yaml

sleep 180
echo "Verifying installation"
oc get pods -n $IAF_PROJECT
