function log() {
    echo " - $"
}

function header() {
    echo "****************************************"
    echo " $1"
    echo "****************************************"
}

function get_instance_id() {
    cd /opt/app/terraform \
    && terraform workspace select ${AWS_ACCOUNT_ID} \
    && terraform output -raw instance_id
}

function create_ssh_config() {
    log "Creating ssh config file"

    INSTANCE_ID=$1
    USERNAME=$2

cat << EOF > /home/${USERNAME}/.ssh/config
Host aws_ec2
    HostName ${INSTANCE_ID}
    User ec2-user
    StrictHostKeyChecking no
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
EOF
}

