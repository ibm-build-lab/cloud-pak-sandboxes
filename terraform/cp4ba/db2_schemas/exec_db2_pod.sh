#!/bin/bash
# set -x
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo
echo
echo "*********************************************************************************"
echo "**************************** Creating DB2 Schemas ... ***************************"
echo "*********************************************************************************"
echo


ibmcloud login -apikey "${IC_API_KEY}"
ibmcloud config --check-version=false
ibmcloud ks cluster config -c "${CLUSTER_ID}" --admin
echo ${KUBECONFIG}
echo


echo "Using ${DB2_POD_NAME} pod for creating the DB2 Schemas ..."
kubectl get pod "${DB2_POD_NAME}" -n "${DB2_PROJECT_NAME}"
echo

echo
echo "Copying the Db2 Schema file to the pod ..."
#kubectl cp db2_schemas/create_db2_schemas.sh "${DB2_PROJECT_NAME}/${DB2_POD_NAME}":/tmp/;
kubectl cp create_db2_schemas.sh "${DB2_PROJECT_NAME}/${DB2_POD_NAME}":/tmp/;
echo
sleep 5

echo
echo "Updating create_db2_schemas.sh file permission ..."
kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- /bin/sh -c "chmod a+x /tmp/create_db2_schemas.sh"

echo
echo "Executing the pod ..."
kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- su - "${DB2_USER}" /bin/sh -c "/tmp/create_db2_schemas.sh ${DB2_PROJECT_NAME} ${DB2_USER}" # ${DB2_DEFAULT_NAME}" # "/tmp/create_db2_schemas.sh ${DB2_PROJECT_NAME} ${DB2_USER} ${DB2_DEFAULT_NAME}"


function activate_database() {
    dbname=$1

    echo "Activating ${dbname} database ..."
    echo
    kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- su - "${DB2_USER}" -c "db2 activate database ${dbname}"
    sleep 5
    echo
}

for name in umsdb appdb basdb bawdb gcddb icndb devos1 aeos bawdocs bawtos bawdos aedb osdb;
do
  activate_database "${name}"
done

echo
echo "Removing the Db2 Schema file from the pod ..."
kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- /bin/sh -c "rm /tmp/create_db2_schemas.sh" # "rm /tmp/create_db2_schemas.sh"

echo
echo "Restarting Db2..."
kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- su - "${DB2_USER}" -c "db2stop"
sleep 5
kubectl -n "${DB2_PROJECT_NAME}" exec "${DB2_POD_NAME}" -i -- su - "${DB2_USER}" -c "db2start"
sleep 5