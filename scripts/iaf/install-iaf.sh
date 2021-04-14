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

# helpful commands:
#   docker exec -it <container name> /bin/bash
#   kubectl describe <resource name>
#   kubectl get <resource> <name> -o yaml
#   kubectl config set-context --current --namespace=<namespace/project>

# Humio VLAN info:
# Name: wdc04
# PVlan: 2876468
# PBVlan: 2876470
# Name: wdc06
# PVlan: 2916302
# PBVlan: 2916300
# Name: dal13
# PVlan: 2847992
# PBVlan: 2847990
# Name: dal10
# PVlan: 2832804
# PBVlan: 2832802
# Name: dal12
# PVlan: 3018046
# PBVlan: 3018044

# Log in to IBM Cloud
#ibmcloud login -sso
#echo "What Resource Group (defaults to cloud-pak-sandbox)?"
#read RESOURCE_GROUP
#RESOURCE_GROUP="${RESOURCE_GROUP:-cloud-pak-sandbox}"
#RESOURCE_GROUP='cloud-pak-sandbox'
#ibmcloud target -g $RESOURCE_GROUP

# Get entitlement key, https://myibm.ibm.com/products-services/containerlibrary
#echo Please go to https://myibm.ibm.com/products-services/containerlibrary for your entitlement key
#echo Enter entitlement key here:
#read E_KEY
E_KEY=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1OTY4MzcwMjUsImp0aSI6IjcwMDNkYmU0ZDczZjQ4Y2M4NmQ4Y2Q5ZWE0YzVlYmY4In0.62Llbq4dGKWhPWOngqBMz5SdMZdbnGYjOFlzmN7Fgvw
#echo What is your IBM email address?
#read EMAIL_ADDR

# Create or get details of OCP Cluster
echo "Do you already have an OpenShift cluster?"
select yn in "y" "n"; do
  case $yn in
  n)
    echo "Creating OpenShift Cluster on IBM Cloud"
    echo "What is the name of new cluster?"
    read CLUSTER
    #    echo "What version of Openshift (defaults to 4.6)?"
    #    read OCP_VERSION
    OCP_VERSION="${OCP_VERSION:-4.6}"
    #    echo "What flavor (defaults to c3c.16x32)?"
    #    echo "ibmcloud ks flavors --zone dal12 --provider classic"
    #    read OCP_FLAVOR
    OCP_FLAVOR="${OCP_FLAVOR:-b3c.16x64}"
    #    echo "How many worker nodes (defaults to 4)?"
    #    read NUM_NODES
    NUM_NODES="${NUM_NODES:-4}"
    echo "What data center (defaults to dal12)?"
    read ZONE
    ZONE="${ZONE:-dal12}"
    ibmcloud sl vlan list -d $ZONE
    echo "Enter private VLAN id for $ZONE:"
    read PVLAN
    #    PVLAN="${PVLAN:-3018046}"
    echo "Enter public VLAN id for $ZONE:"
    read PBVLAN
    #    PBVLAN="${PBVLAN:-3018044}"
    echo "Creating Cluster"
    echo "ibmcloud oc cluster create classic --name ${CLUSTER} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}"
    ibmcloud oc cluster create classic --name ${CLUSTER} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}
    # Documentation on how to access cluster: https://cloud.ibm.com/docs/openshift?topic=openshift-access_cluster
    echo "Waiting for cluster to come up..."
    date

    # try command every 5 minutes for an hour or until it returns success
    for ((time = 0; time < 12; time++)); do
      echo ibmcloud oc cluster config -c $CLUSTER --admin
      if ibmcloud oc cluster config -c $CLUSTER --admin; then
        break
      fi
      echo "Trying again in 5 minutes"
      sleep 300
    done
    break
    ;;
  y)
    echo What is the name of existing cluster to use?
    read CLUSTER
    ibmcloud oc cluster config -c $CLUSTER --admin
    break
    ;;
  esac
done

CLUSTER_URL=$(kubectl cluster-info | sed -n -e 's/^.*at //p')
echo "Cluster is ready and console can be accessed via $CLUSTER_URL"
# create namespace to install IAF
kubectl create namespace iaf
kubectl config set-context --current --namespace=iaf

# Create secret from entitlement key
echo "Create secret from entitlement key"
export CP_ICR_IO=cp.icr.io
export CP_ICR_IO_USER=cp
export CP_ICR_IO_KEY=$E_KEY
./pre-install.sh

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
oc get pods -n iaf
