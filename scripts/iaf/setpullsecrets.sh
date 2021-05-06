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

echo "Is OpenShift Cluster on VPC ('true' or 'false'). Defaults to 'false'?"
read ON_VPC
ON_VPC="${ON_VPC:-false}"
if [[ $ON_VPC == "true" ]]; then
  action=replace
else
  action=reload
fi

worker_count=0
for worker in $(ibmcloud ks workers --cluster ${CLUSTER} | grep kube | awk '{ print $1 }'); 
do echo "reloading worker";
  echo "ibmcloud oc worker $action --cluster ${CLUSTER} -w $worker -f";
  ibmcloud oc worker $action --cluster ${CLUSTER} -w $worker -f; 
  worker_count=$((worker_count + 1))
done

echo "Completed setting pull secrets and restarting workers"
echo "Waiting for workers to restart ..."
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
    echo "Waiting for workers to delete"
    sleep 180s
    oc get nodes | grep SchedulingDisabled
    result=$?
done

# Loop until all workers are in Ready state
result=$(oc get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
counter=0
while [[ $result -lt $worker_count ]]
do
    if [[ $counter -gt 10 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for all $worker_count workers to restart"
    sleep 180s
    result=$(oc get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
done

