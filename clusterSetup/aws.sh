#!/bin/bash

set -euxo pipefail

# Configurable variables
AWS_REGION=ap-south-1
VPC_NAME=kubernetes-from-scratch
SUBNET_NAME=kubernetes-pvt
IG_NAME=kubernetes-igw
RT_NAME=kubernetes-rt
SG_NAME=kubernetes-sg
KEY_PAIR_NAME=kubernetes
CONTROLLER_NAME_PREFIX=controller
WORKER_NAME_PREFIX=worker
CIDR_BLOCK=10.0.0.0/16
SUBNET_CIDR_BLOCK=10.0.1.0/24
CONTROLLER_COUNT=1
WORKER_COUNT=1
IMAGE_OWNER=099720109477
INSTANCE_TYPE_CONTROLLER=t2.large
INSTANCE_TYPE_WORKER=t2.xlarge
DEVICE_NAME="/dev/sda1"
VOLUME_SIZE=50

aws configure set default.region $AWS_REGION

VPC_ID=$(aws ec2 create-vpc --cidr-block $CIDR_BLOCK --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources ${VPC_ID} --tags Key=Name,Value=$VPC_NAME
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-support '{"Value": true}'
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-hostnames '{"Value": true}'

SUBNET_ID=$(aws ec2 create-subnet --vpc-id ${VPC_ID} --cidr-block $SUBNET_CIDR_BLOCK --output text --query 'Subnet.SubnetId')
aws ec2 create-tags --resources ${SUBNET_ID} --tags Key=Name,Value=$SUBNET_NAME

INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')
aws ec2 create-tags --resources ${INTERNET_GATEWAY_ID} --tags Key=Name,Value=$IG_NAME
aws ec2 attach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_ID}

ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id ${VPC_ID} --output text --query 'RouteTable.RouteTableId')
aws ec2 create-tags --resources ${ROUTE_TABLE_ID} --tags Key=Name,Value=$RT_NAME
aws ec2 associate-route-table --route-table-id ${ROUTE_TABLE_ID} --subnet-id ${SUBNET_ID}
aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${INTERNET_GATEWAY_ID}

SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description "Kubernetes from scratch - security group" --vpc-id ${VPC_ID} --output text --query 'GroupId')
aws ec2 create-tags --resources ${SECURITY_GROUP_ID} --tags Key=Name,Value=$SG_NAME

SEC_RULES=(
  "22 tcp 0.0.0.0/0"
  "6443 tcp 0.0.0.0/0"
  "443 tcp 0.0.0.0/0"
  "-1 icmp 0.0.0.0/0"
  "179 tcp $CIDR_BLOCK"
  "4789 udp $CIDR_BLOCK"
  "5473 tcp $CIDR_BLOCK"
  "51820 udp $CIDR_BLOCK"
  "51821 udp $CIDR_BLOCK"
  "2379 tcp $CIDR_BLOCK"
  "2380 tcp $CIDR_BLOCK"
  "10251 tcp $CIDR_BLOCK"
  "10252 tcp $CIDR_BLOCK"
  "10250 tcp $CIDR_BLOCK"
  "10257 tcp $CIDR_BLOCK"
  "10259 tcp $CIDR_BLOCK"
  "10256 tcp $CIDR_BLOCK"
  "1433 tcp $CIDR_BLOCK"
)

for rule in "${SEC_RULES[@]}"; do
  IFS=" " read -r port proto cidr <<< "$rule"
  aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol $proto --port $port --cidr $cidr
done
brew install jq

IMAGE_ID=$(aws ec2 describe-images \
  --owners $IMAGE_OWNER \
  --output json \
  --filters "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64" "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-*" | \
  jq -r '.Images | sort_by(.CreationDate) | last | .ImageId')

# Create key pair
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --output text --query 'KeyMaterial' > ${KEY_PAIR_NAME}.id_rsa
chmod 600 ${KEY_PAIR_NAME}.id_rsa

# Run controller instances
for ((i=0; i<$CONTROLLER_COUNT; i++)); do
  instance_id=$(aws ec2 run-instances \
    --associate-public-ip-address \
    --image-id "$IMAGE_ID" \
    --count 1 \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --instance-type $INSTANCE_TYPE_CONTROLLER \
    --private-ip-address "10.0.1.1${i}" \
    --user-data "name=${CONTROLLER_NAME_PREFIX}-${i}" \
    --subnet-id "$SUBNET_ID" \
    --block-device-mappings "{\"DeviceName\": \"$DEVICE_NAME\", \"Ebs\": { \"VolumeSize\": $VOLUME_SIZE }, \"NoDevice\": \"\" }" \
    --region "ap-south-1" \
    --placement "AvailabilityZone=ap-south-1a" \
    --output text --query 'Instances[].InstanceId')

  aws ec2 modify-instance-attribute --instance-id "$instance_id" --no-source-dest-check
  aws ec2 create-tags --resources "$instance_id" --tags "Key=Name,Value=${CONTROLLER_NAME_PREFIX}-${i}"
  echo "${CONTROLLER_NAME_PREFIX}-${i} created "
done

# Run worker instances
for ((i=0; i<$WORKER_COUNT; i++)); do
  instance_id=$(aws ec2 run-instances \
    --associate-public-ip-address \
    --image-id "$IMAGE_ID" \
    --count 1 \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --instance-type $INSTANCE_TYPE_WORKER \
    --private-ip-address "10.0.1.2${i}" \
    --user-data "name=${WORKER_NAME_PREFIX}-${i}|pod-cidr=10.200.${i}.0/24" \
    --subnet-id "$SUBNET_ID" \
    --block-device-mappings "{\"DeviceName\": \"$DEVICE_NAME\", \"Ebs\": { \"VolumeSize\": $VOLUME_SIZE }, \"NoDevice\": \"\" }" \
    --region "ap-south-1" \
    --placement "AvailabilityZone=ap-south-1a" \
    --output text --query 'Instances[].InstanceId')

  aws ec2 modify-instance-attribute --instance-id "$instance_id" --no-source-dest-check
  aws ec2 create-tags --resources "$instance_id" --tags "Key=Name,Value=${WORKER_NAME_PREFIX}-${i}"
  echo "${WORKER_NAME_PREFIX}-${i} created"
done

sleep 20

# Generate our SSH command line arguments to be able to connect to our controller and worker instances
for instance in $(seq 0 $(($CONTROLLER_COUNT - 1))); do
  external_ip=$(aws ec2 describe-instances --filters \
    "Name=tag:Name,Values=${CONTROLLER_NAME_PREFIX}-${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  echo ssh -i ${KEY_PAIR_NAME}.id_rsa ubuntu@$external_ip
done

for instance in $(seq 0 $(($WORKER_COUNT - 1))); do
  external_ip=$(aws ec2 describe-instances --filters \
    "Name=tag:Name,Values=${WORKER_NAME_PREFIX}-${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  echo ssh -i ${KEY_PAIR_NAME}.id_rsa ubuntu@$external_ip
done


# ssh -i kubernetes.id_rsa ubuntu@13.201.56.206
# ssh -i kubernetes.id_rsa ubuntu@13.232.53.204