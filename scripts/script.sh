#!/bin/bash

############################################################
# Enterprise AWS IRE Ansible Collection Skeleton
# Author : Yoganand
############################################################

set -e

REPO="ire-aws-iac-ansible-modules"

echo "Creating repository: $REPO"

mkdir -p "$REPO"
cd "$REPO"

############################################################
# Root Directories
############################################################

mkdir -p \
.github/workflows \
collections/ansible_collections/yoganand/aws \
docs \
examples \
inventories/{dev,test,prod} \
playbooks \
terraform \
vars

############################################################
# Collection Structure
############################################################

COLLECTION_ROOT="collections/ansible_collections/yoganand/aws"

mkdir -p \
$COLLECTION_ROOT/docs \
$COLLECTION_ROOT/meta \
$COLLECTION_ROOT/plugins/modules \
$COLLECTION_ROOT/plugins/module_utils \
$COLLECTION_ROOT/plugins/filter \
$COLLECTION_ROOT/plugins/lookup \
$COLLECTION_ROOT/roles

############################################################
# Enterprise Roles
############################################################

roles=(

assume_role
aws_api_credentials

kms

vpc
subnet
internet_gateway
nat_gateway
elastic_ip
route_table
network_acl
security_group
vpc_peering
transit_gateway
client_vpn

managed_ad

iam_role
iam_policy
iam_user

s3_bucket
dynamodb

lambda
api_gateway

ec2
ebs
launch_template
autoscaling

cloudwatch
sns
secrets_manager

backup_vault
backup_plan

drs

tagging
validations
outputs

)

############################################################
# Create Role Skeleton
############################################################

for role in "${roles[@]}"
do

mkdir -p \
$COLLECTION_ROOT/roles/$role/defaults \
$COLLECTION_ROOT/roles/$role/tasks \
$COLLECTION_ROOT/roles/$role/handlers \
$COLLECTION_ROOT/roles/$role/meta \
$COLLECTION_ROOT/roles/$role/vars \
$COLLECTION_ROOT/roles/$role/templates \
$COLLECTION_ROOT/roles/$role/files

touch \
$COLLECTION_ROOT/roles/$role/defaults/main.yml \
$COLLECTION_ROOT/roles/$role/tasks/main.yml \
$COLLECTION_ROOT/roles/$role/handlers/main.yml \
$COLLECTION_ROOT/roles/$role/meta/main.yml \
$COLLECTION_ROOT/roles/$role/vars/main.yml \
$COLLECTION_ROOT/roles/$role/README.md

done

############################################################
# Playbooks
############################################################

touch playbooks/bootstrap.yml
touch playbooks/networking.yml
touch playbooks/security.yml
touch playbooks/storage.yml
touch playbooks/compute.yml
touch playbooks/recovery.yml
touch playbooks/destroy.yml

############################################################
# Root Files
############################################################

touch \
README.md \
LICENSE \
CHANGELOG.md \
CONTRIBUTING.md \
ansible.cfg \
requirements.yml

############################################################
# Collection Files
############################################################

touch \
$COLLECTION_ROOT/README.md \
$COLLECTION_ROOT/runtime.yml \
$COLLECTION_ROOT/galaxy.yml \
$COLLECTION_ROOT/meta/runtime.yml

############################################################
# Git Ignore
############################################################

cat <<EOF > .gitignore

*.retry
*.pyc
__pycache__/
.env
.venv
.vscode
.idea
collections.tar.gz
*.log

EOF

############################################################
# Github Workflow Placeholders
############################################################

touch .github/workflows/lint.yml
touch .github/workflows/test.yml
touch .github/workflows/release.yml

############################################################
# Complete
############################################################

echo
echo "======================================="
echo "Repository skeleton created successfully"
echo "======================================="
echo

tree -L 4
