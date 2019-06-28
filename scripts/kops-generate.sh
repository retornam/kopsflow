#!/bin/bash

source exports.sh

# master-zones: default is 3. 1  master in each AZ (availability zone)
# zones: AZs 
# topology: we want private here so instances live in private subnets
# dns-zone: default Route-53 DNS zone 
# networking: default calico
# vpc: AWS VPC ID
# target: generate Terraform
# out: dump terraform to current folder
# bastion: create bastion host
# ssh-public-key: path to our public key
kops create cluster \
        --cloud aws \
        --node-count 3 \
        --node-size t2.micro \
        --master-size t2.micro \
        --bastion \
        --authorization=RBAC \
	--master-zones ${ZONES} \
	--zones ${ZONES} \
	--topology private \
	--dns-zone ${DNSZONEID}  \
	--networking ${K8SNETWORKING} \
	--vpc ${VPCID} \
	--target=terraform \
	--out=. \
        ${CLUSTER_NAME}

#create ssh key
kops create secret \
	--name ${NAME} \
	sshpublickey admin -i ${PUBLICKEY}
