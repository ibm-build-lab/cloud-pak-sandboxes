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
DB2_DEFAULT_NAME="sample-db"
DB2_USER="db2inst1"
DB2_PROJECT_NAME="ibm-db2"
DB2_POD_NAME="c-db2ucluster-db2u-0"

#echo $CUR_DIR

echo
echo
echo "*********************************************************************************"
echo "**************************** Creating DB2 Schemas ... ***************************"
echo "*********************************************************************************"

echo
kubectl cp create_db2_schemas.sh "${DB2_POD_NAME}":/tmp/ # ;
echo
sleep 5
kubectl exec "${DB2_POD_NAME}" -- su - "${DB2_USER}" /bin/sh -c "chmod a+x /tmp/create_db2_schemas.sh" # "chmod a+x /tmp/create_db2_schemas.sh"

#./"${CUR_DIR}"

kubectl exec "${DB2_POD_NAME}" -- su - "${DB2_USER}" -c "/tmp/create_db2_schemas.sh ${DB2_PROJECT_NAME} ${DB2_USER} ${DB2_DEFAULT_NAME}" # "/tmp/create_db2_schemas.sh ${DB2_PROJECT_NAME} ${DB2_USER} ${DB2_DEFAULT_NAME}"
kubectl exec "${DB2_POD_NAME}" -- /bin/sh -c "rm /tmp/create_db2_schemas.sh" # "rm /tmp/create_db2_schemas.sh"

function activate_database() {
    dbname=$1

    echo "Activating ${dbname} database ..."
    echo
    kubectl exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" -c "db2 activate database ${dbname}"
    sleep 5
    echo
}

for name in umsdb appdb basdb bawdb gcddb icndb devos1 aeos bawdocs bawtos bawdos aedb osdb;
do
#  dbname="${name}" #${DB2_DEFAULT_NAME}-
#  activate_database "${dbname}"
  activate_database "${name}"
#  if [ $name == umsdb ]
#  then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_umsdb "${dbname}"
#      create_umsdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == appdb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_appdb "${dbname}"
#      create_appdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == basdb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_basdb "${dbname}"
#      create_basdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == bawdb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_bawdb "${dbname}"
#      create_bawdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == gcddb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_gcddb "${dbname}"
#      create_gcddb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == icndb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_icndb "${dbname}"
#      create_icndb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == osdb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == devos1 ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == aeos ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == bawdocs ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == bawtos ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == bawdos ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_osdb "${dbname}"
#      create_osdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  elif [ $name == aedb ]; then
##      oc -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" | create_appdb "${dbname}"
#      create_appdb "${dbname}"
#      activate_database "${dbname}"
#      echo
#  else
#      continue
#  fi
done


echo
echo "Restarting Db2..."
kubectl exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" -c "db2stop"
sleep 5
kubectl exec c-db2ucluster-db2u-0 -- su - "${DB2_USER}" -c "db2start"
sleep 5