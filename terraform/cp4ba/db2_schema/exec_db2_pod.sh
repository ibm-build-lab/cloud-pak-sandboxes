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

kubectl cp "${CUR_DIR}"/db2_schema/create_db2_schemas.sh "${DB2_POD_NAME}":/tmp/;
kubectl exec "${DB2_POD_NAME}" -it -- /bin/sh -c "chmod a+x /tmp/create_db2_schemas.sh"

#./"${CUR_DIR}"
#
kubectl exec c-db2ucluster-db2u-0 -it -- su - "${DB2_USER}" -c "/tmp/create_db2_schemas.sh ${DB2_PROJECT_NAME} ${DB2_USER} ${DB2_DEFAULT_NAME}"
kubectl exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/create_db2_schemas.sh"