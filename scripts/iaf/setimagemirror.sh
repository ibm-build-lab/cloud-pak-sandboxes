oc delete -f ./setimagemirror.yaml -n kube-system
oc create -f ./setimagemirror.yaml -n kube-system
sleep 120
oc get pods -n kube-system | grep iaf-enable-mirrors

for worker in $(ibmcloud ks workers --cluster $CLUSTER | grep kube | awk '{ print $1 }'); \
  do echo "reloading worker"; \
  ibmcloud oc worker reboot --cluster $CLUSTER -w $worker -f; \
  done

# wait 10 minutes for reboots to complete
sleep 600
