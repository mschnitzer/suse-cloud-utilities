#!/bin/bash
# start pacemaker for each node
#
# exit status greater than 0: something went wrong

EXIT=0

if [ ! -f /opt/dell/crowbar_framework/.crowbar-installed-ok ]; then
    echo "please run this script on the crowbar node."
    exit 1
fi

for node in $(crowbar machines list); do
    if [ ! -z $(crowbar machines show $node roles | grep pacemaker-cluster-member) ]; then
        ssh $node "rcopenais start > /dev/null 2>&1"
        EXIT=$?

        if [[ $EXIT == "0" ]]; then
            STATUS="$(tput setaf 2)done$(tput sgr0)"
        else
            STATUS="$(tput setaf 1)error$(tput sgr0)"
        fi

        echo "[$STATUS] Starting Pacemaker on node $node"
        if [ $EXIT -gt 0 ]; then
            exit $EXIT
        fi
    fi
done
