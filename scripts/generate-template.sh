#!/bin/bash

set -e -o pipefail

export REGION=$(cd ../terraform/vpcsetup && terraform output awsRegion)
export CLUSTERNAME=$(cd ../terraform/vpcsetup && terraform output clusterName)
export KOPS_STATE_STORE=$(cd ../terraform/vpcsetup && terraform output s3_bucket)

SSH_PUBLIC_KEY=${1:-$HOME/.ssh/id_rsa.pub}


# create cluster yaml from template file
echo "Creating cluster.yaml file"
kops toolbox template --values ../secrets/values.yaml \
	--template ../templates/clusterte.tpl \
	--output ../secrets/cluster.yaml 

echo "cluster.yaml file created."

cat cluster.yaml

read -p "Run kops create cluster? (y/n)? " answer
case ${answer:0:1} in
    "y") 
        echo "Creating cluster using cluster.yaml file"
        kops create -f ../secrets/cluster.yaml --state=${KOPS_STATE_STORE}
        ;;
    *)
        echo "Exiting."
        exit
        ;;
esac



echo "Create cluster SSH pubkey secret with ${SSH_PUBLIC_KEY}?"
read -p "Run kops create cluster? (y/n)? " answerssh
case ${answerssh:0:1} in
    "y") 
        echo "Creating cluster using cluster.yaml file"
        kops create secret --name ${CLUSTERNAME} \
            sshpublickey admin  -i $SSH_PUBLIC_KEY}  \
            --state=${KOPS_STATE_STORE}
        ;;
    *)
        echo "Exiting."
        exit
        ;;
esac

echo "${SSH_PUBLIC_KEY} added successfully."

echo "Running kops update cluster --dry-run"
kops update cluster ${CLUSTERNAME} --state=${KOPS_STATE_STORE}

read -p "Commit changes ? [y|n]" answerupdate
case ${answerupdate:0:1} in
    "y") 
        echo "Creating cluster using cluster.yaml file"
        kops update cluster ${CLUSTERNAME} --state=${KOPS_STATE_STORE} \
        --target=terraform  \
		--out ../terraform/kubernetessetup/ --yes
        ;;
    *)
        echo "Exiting."
        exit
        ;;
esac
echo "Changes Applied"

echo "Validating cluster"
kops validate cluster ${CLUSTERNAME} --state=${KOPS_STATE_STORE}
