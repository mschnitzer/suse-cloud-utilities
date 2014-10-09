#!/bin/bash
#
# this script starts chef on all nodes in the cloud
#
# exit status 0: everything was fine :)
# exit status 1: the script was not runnig on the crowbar node

TMP_FILE="startup_chef_script.tmp"

if [ ! -f /opt/dell/crowbar_framework/.crowbar-installed-ok ]; then
  echo "please run this script on the crowbar node."
  exit 1
fi

for node in $(crowbar machines list); do
    if [ ! -z $(crowbar machines show $node roles | grep \"crowbar\") ]; then 
        rcchef-client start > /dev/null
    else
        ssh $node rcchef-client start &> /tmp/$TMP_FILE
    fi

    if [[ $? == "0" ]]; then
        STATUS="$(tput setaf 2)done$(tput sgr0)"
        ERROR_MSG=""
    else
        STATUS="$(tput setaf 1)error$(tput sgr0)"
    
        ERROR_MSG=""
        if [ ! -z "$(cat /tmp/$TMP_FILE | grep "No route to host")" ]; then
            ERROR_MSG=" (could not reach node through ssh - maybe off?)"
        fi
    fi

    echo "[$STATUS] Starting chef client on node $node$ERROR_MSG"
done

rm /tmp/$TMP_FILE
