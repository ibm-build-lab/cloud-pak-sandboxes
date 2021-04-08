#!/bin/bash
# Script to configure cluster before IAF instalation scripts are run

# Set the users and keys for container registries and name of the cluster in this env file
source ./iafenv.config

oc extract secret/pull-secret -n openshift-config --confirm --to=. 
jq --arg apikey `echo -n "$CP_ICR_IO_USER:$CP_ICR_IO_KEY" | base64` --arg registry "$CP_ICR_IO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
jq --arg apikey `echo -n "$CP_STG_ICR_IO_USER:$CP_STG_ICR_IO_KEY" | base64` --arg registry "$CP_STG_ICR_IO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
jq --arg apikey `echo -n "$ARTIFACTORY_USER:$ARTIFACTORY_APIKEY" | base64` --arg registry "$ARTIFACTORY_REPO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
jq --arg apikey `echo -n "$DOCKER_IO_USER:$DOCKER_IO_KEY" | base64` --arg registry "$DOCKER_IO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson  
rm .dockerconfigjson

for worker in $(ibmcloud ks workers --cluster $CLUSTER | grep kube | awk '{ print $1 }'); \
  do echo "reloading worker"; \
  ibmcloud oc worker reload --cluster $CLUSTER -w $worker -f; \
  done

echo "Completed setting pull secrets and sending command to reload workers..."

oc get nodes | grep SchedulingDisabled
result=$?
counter=0
while [[ "${result}" -eq 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for workers to reload"
    sleep 180s
    oc get nodes | grep SchedulingDisabled
    result=$?
done

oc create -f setimagemirror.yaml -n kube-system
# TODO - add a check to make sure initContainer has finished
echo "Waiting for daemonset to update image mirror config for workers"
sleep 120
oc get pods -n kube-system | grep iaf-enable-mirrors
oc delete -f setimagemirror.yaml -n kube-system

for worker in $(ibmcloud ks workers --cluster $CLUSTER | grep kube | awk '{ print $1 }'); \
  do echo "rebooting worker"; \
  ibmcloud oc worker reboot --cluster $CLUSTER -w $worker -f; \
  done

# wait 10 minutes for reboots to complete
echo "Completed setting up registry mirrors, going to sleep for 10 minutes..."
sleep 600

# create storage class expected by installer
# cat <<EOF | oc apply -f -
# allowVolumeExpansion: true
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
  # annotations:
    # storageclass.kubernetes.io/is-default-class: "false"
    # addonmanager.kubernetes.io/mode: EnsureExists
    # kubernetes.io/cluster-service: "true"
  # name: rook-cephfs
# parameters:
  # billingType: hourly
  # classVersion: "2"
  # gidAllocate: "true"
  # iopsPerGB: "10"
  # sizeRange: '[20-4000]Gi'
  # type: Endurance
# provisioner: ibm.io/ibmc-file
# reclaimPolicy: Delete
# volumeBindingMode: Immediate
# EOF

