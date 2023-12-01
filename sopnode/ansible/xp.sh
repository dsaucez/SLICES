#!/bin/bash

## Configuration
ARCHIVE_SERVER="http://mrs:1234"
MRS_BACKEND="http://mrs:9001"
MRS_FRONTEND="http://mrs:9002"
UPLOAD_URI="${ARCHIVE_SERVER}/upload"

##
UUID=`cat /proc/sys/kernel/random/uuid`
TIMESTAMP=`date -u +%s.%N`
DATE=`date +%Y-%m-%d_%H-%M-%S-%Z`
DIR="$(pwd)/dataset/$DATE/"
LANDING_DIR=`pwd`

DATETIMESTART=$TIMESTAMP

echo "Experiment ${UUID} be saved in ${DIR}"

#mkdir xp
#cd xp
#
#git clone https://github.com/dsaucez/SLICES.git --branch xp
#cd SLICES/sopnode/ansible/
mkdir -p $DIR

# Log level
# ansible
SLICES_ANSIBLE_LOG_PATH=$DIR/ansible.log

## Install dependencies
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-galaxy install -r requirements.xp.yml
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook xp.yaml


## Provision the infrastructure
mkdir _terraform
pushd .
cd _terraform
git clone https://github.com/dsaucez/SLICES.git --branch 41-modularize-terraform 
popd
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ provision.yaml --extra-vars "@params.blueprint.xp.yaml" --extra-vars "terraform_project_path=_terraform/SLICES/sopnode/terraform"
cp _terraform/SLICES/sopnode/terraform/inventory ${LANDING_DIR}/inventories/blueprint/xp/hosts
cp _terraform/SLICES/sopnode/terraform/inventory ${DIR}

# Prepare the cluster
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ k8s-master.yaml --extra-vars "@params.blueprint.xp.yaml"
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ k8s-node.yaml --extra-vars "@params.blueprint.xp.yaml"

# Deploy 5G
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ 5g.yaml --extra-vars "@params.blueprint.xp.yaml"

# Run experiment
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ 5g_test.yaml --extra-vars "@params.blueprint.xp.yaml"

# Retrieve experiment results
ANSIBLE_LOG_PATH=$SLICES_ANSIBLE_LOG_PATH ansible-playbook  -i inventories/blueprint/xp/ dataset.yaml --extra-vars "@params.blueprint.xp.yaml"  --extra-vars "dataset=$DIR"

DATETIMEEND=`date -u +%s.%N`

archive_data () {
# Archive the dataset
  local DATASET="dataset-${UUID}-${DATE}.tar.gz"
  tar -czf ${DATASET} ${DIR}
  curl -X POST ${UPLOAD_URI} -F "files=@${DATASET}"
  echo ${DATASET}
}

DATASET=$(archive_data)

# Publish the dataset
export SLICES_DATASET_SIZE=`wc -c < $DATASET`
export SLICES_DATASET_DATE=`date +'%Y-%m-%dT%T.%3NZ' -d "@$TIMESTAMP"`
export SLICES_DATETIMESTART=`date +'%Y-%m-%dT%T.%3NZ' -d "@$DATETIMESTART"`
export SLICES_DATETIMEEND=`date +'%Y-%m-%dT%T.%3NZ' -d "@$DATETIMEEND"`
export SLICES_IDENTIFIER=$UUID

export SLICES_DATASET_URI="${ARCHIVE_SERVER}/${DATASET}"

id=$(envsubst '$SLICES_DATASET_SIZE $SLICES_DATASET_DATE $SLICES_DATASET_URI $SLICES_DATETIMESTART $SLICES_DATETIMEEND $SLICES_IDENTIFIER' < body.json | curl -X 'POST' "${MRS_BACKEND}/v0.2/digital-objects" -H 'accept: application/json' -H 'Content-Type: application/json' -d "@-")


echo "Dataset available at ${MRS_FRONTEND}/app/sfdo/${id}"

unset SLICES_DATASET_SIZE
unset SLICES_DATASET_DATE
unset SLICES_DATASET_URI
unset SLICES_DATETIMESTART
unset SLICES_DATETIMEEND
unset SLICES_IDENTIFIER
