

#ibmcloud sl vlan list --output json > vlan.json
DATACENTER=dal13
VLAN_PRIVATE_OPTION="0"
VLAN_OPTION="0"
LENGTH="0"

echo $DATACENTER

echo "public vlans found"
jq --arg v "$DATACENTER" '[.[] | select(.primaryRouter.datacenter.name | contains($v)) | select(.networkSpace | contains("PUBLIC"))]' vlan.json > vlan-public.json
echo "private vlans found"
jq --arg v "$DATACENTER" '[.[] | select(.primaryRouter.datacenter.name | contains($v)) | select(.networkSpace | contains("PRIVATE"))]' vlan.json > vlan-private.json

write_private_vlan() {
    echo "writing vlan"
}

create_private_vlan() {
    echo "creating private vlan"
    ibmcloud sl vlan create -t private -d $DATACENTER -n sandbox-private -f --output json > vlan-private-$WORKSPACE_NAME.json
    echo "Private Vlan creation started, this process may take some time. You may continue to refresh the vlan list until it appears, cancel this current sandbox creation, or choose another vlan"
    ibmcloud sl vlan list --output json > vlan.json
    jq --arg v "$DATACENTER" '[.[] | select(.primaryRouter.datacenter.name | contains($v)) | select(.networkSpace | contains("PRIVATE"))]' vlan.json > vlan-private.json
}

get_private_vlan() {
    VLAN_PRIVATE_OPTION="0"
    echo "$VLAN_PRIVATE_OPTION"
    while true;
    do
        for (( c=1; c<=$LENGTH; c++))
        do 
            TEMP=$(jq -c ".[$c] | {id: .id, name: .name, vlanNumber: .vlanNumber, datacenter: .primaryRouter.datacenter.name}" vlan-private.json )
            echo $c". "$TEMP
        done
        echo $c".  Create your new private vlan"
        echo "Type 0 to refresh available vlans"
        read -p "${bold}Choose a private vlan option:${normal} " -e VLAN_PRIVATE_OPTION

        if (($VLAN_PRIVATE_OPTION == $c))
        then create_private_vlan
        elif (($VLAN_PRIVATE_OPTION>0)) && (($VLAN_PRIVATE_OPTION<=$LENGTH))
        then write_private_vlan
             break
        elif (($VLAN_PRIVATE_OPTION == 0))
        then echo "Refrehing Private Vlans..."
                ibmcloud sl vlan list --output json > vlan.json
                jq --arg v "$DATACENTER" '[.[] | select(.primaryRouter.datacenter.name | contains($v)) | select(.networkSpace | contains("PRIVATE"))]' vlan.json > vlan-private.json
        else echo "PLEASE TRY AGAIN"
                ibmcloud sl vlan list --output json > vlan.json
                jq --arg v "$DATACENTER" '[.[] | select(.primaryRouter.datacenter.name | contains($v)) | select(.networkSpace | contains("PRIVATE"))]' vlan.json > vlan-private.json
        fi
    done    
}

write_public_vlan() {
    echo "writing vlan"
}

create_public_vlan() {
    echo "creating public vlan"
    ibmcloud sl vlan create -t public -d $DATACENTER -n sandbox-$DATACENTER-public -f --output json > vlan-public-$WORKSPACE_NAME.json
}

get_public_vlan() {
    VLAN_PUBLIC_OPTION="0"
    echo "$VLAN_PUBLIC_OPTION"
    while true;
    do
        for (( c=1; c<=$LENGTH; c++))
        do 
            TEMP=$(jq -c ".[$c] | {id: .id, vlanNumber: .vlanNumber, datacenter: .primaryRouter.datacenter.name}" vlan-public.json )
            echo $c". "$TEMP
        done
        echo $c".  Create your new public vlan"
        read -p "${bold}Choose a public vlan option${normal} " -e VLAN_PUBLIC_OPTION
        if (($VLAN_PUBLIC_OPTION == $c))
        then create_public_vlan
             break
        elif (($VLAN_PUBLIC_OPTION>0)) && (($VLAN_PUBLIC_OPTION<=$LENGTH))
        then write_public_vlan
             break
        else echo "PLEASE TRY AGAIN"
        fi
    done    
}

LENGTH=$(jq length vlan-private.json)
if (($LENGTH))
then
    echo "length is not empty"
    get_private_vlan
else
    echo "length is  empty"
    create_private_vlan
fi

LENGTH=$(jq length vlan-public.json)
if (($LENGTH))
then
    echo "length is not empty"
    get_public_vlan
else
    echo "length is  empty"
    create_public_vlan
fi



#if   
#    ibmcloud sl vlan create -t public -d $DATACENTER -n sandbox-$DATACENTER-public -f --output json > vlan-public-$WORKSPACE_NAME.json
#    ibmcloud sl vlan list -d $DATACENTER --sortby number > vlan-public.json