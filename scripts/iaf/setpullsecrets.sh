#!/bin/bash
# Script to configure cluster before IAF instalation scripts are run

# Set the users and keys for container registries and name of the cluster in this env file
# TODO before running this script
# cp _template-iaf.config iafenv.config
# fill in requested details
# source ./iafenv.config

oc extract secret/pull-secret -n openshift-config --confirm --to=. 
jq --arg apikey `echo -n "$CP_ICR_IO_USER:$CP_ICR_IO_KEY" | base64` --arg registry "$CP_ICR_IO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
jq --arg apikey `echo -n "$CP_STG_ICR_IO_USER:$CP_STG_ICR_IO_KEY" | base64` --arg registry "$CP_STG_ICR_IO" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
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

