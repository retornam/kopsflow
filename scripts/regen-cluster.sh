#!/usr/bin/env bash

set -e -o pipefail

export REGION=$(cd ../terraform/vpcsetup && terraform output awsRegion)
export CLUSTERNAME=$(cd ../terraform/vpcsetup && terraform output clusterName)
export KOPS_STATE_STORE=$(cd ../terraform/vpcsetup && terraform output s3_bucket)

kops toolbox template --values ../secrets/values.yaml \
	--template ../templates/clusterte.tpl \
	--output ../secrets/cluster.yaml 

#force replace existing cluster.yaml file in s3
kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --yes
kops validate cluster ${CLUSTERNAME} --state=${KOPS_STATE_STORE}