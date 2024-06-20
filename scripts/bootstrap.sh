#!/bin/env bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $BASEDIR/inc.sh

header "Bootstraping EC2 instance"

# get the instance id from Terraform state
INSTANCE_ID=$(get_instance_id)
echo "INSTANCE_ID=$INSTANCE_ID"

# create ssh config file
create_ssh_config $INSTANCE_ID $USERNAME

cd /opt/app/ansible
ansible-playbook -i hosts --extra-vars 'instance_id=${INSTANCE_ID} selected_roles=["bootstrap"]' main.yml

