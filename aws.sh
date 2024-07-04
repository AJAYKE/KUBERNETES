#!/bin/bash

set -euxo pipefail

AWS_REGION=ap-south-1
aws configure set default.region $AWS_REGION

VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources ${VPC_ID} --tags Key=Name,Value=kubernetes-from-scratch
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-support '{"Value": true}'
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-hostnames '{"Value": true}'


SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.1.0/24 \
  --output text --query 'Subnet.SubnetId')
aws ec2 create-tags --resources ${SUBNET_ID} --tags Key=Name,Value=kubernetes-pvt

INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')
aws ec2 create-tags --resources ${INTERNET_GATEWAY_ID} --tags Key=Name,Value=kubernetes-igw
aws ec2 attach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_ID}


ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id ${VPC_ID} --output text --query 'RouteTable.RouteTableId')
aws ec2 create-tags --resources ${ROUTE_TABLE_ID} --tags Key=Name,Value=kubernetes-rt
aws ec2 associate-route-table --route-table-id ${ROUTE_TABLE_ID} --subnet-id ${SUBNET_ID}
aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${INTERNET_GATEWAY_ID}

# ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id vpc-0b0214f854777b2bd --output text --query 'RouteTable.RouteTableId')
# aws ec2 associate-route-table --route-table-id ${ROUTE_TABLE_ID} --subnet-id subnet-041145e8449431526
# aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id igw-09a7f58799c3f8bb2


SECURITY_GROUP_ID=$(aws ec2 create-security-group \
  --group-name kubernetes-from-scratch \
  --description "Kubernetes from scratch - security group" \
  --vpc-id ${VPC_ID} \
  --output text --query 'GroupId')
aws ec2 create-tags --resources ${SECURITY_GROUP_ID} --tags Key=Name,Value=kubernetes-sg
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 6443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol 4 --port -1 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 179 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol udp --port 4789 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 5473 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol udp --port 51820 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol udp --port 51821 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 2379 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 2380 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10251 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10252 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10250 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10257 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10259 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 10256 --cidr 10.0.0.0/16
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 1433 --cidr 10.0.0.0/16


brew install jq

IMAGE_ID=$(aws ec2 describe-images \
  --owners 099720109477 \
  --output json \
  --filters \
  "Name=root-device-type,Values=ebs" \
  "Name=architecture,Values=x86_64" \
  "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-*" | \
  jq -r '.Images | sort_by(.CreationDate) | last | .ImageId')

# Create key pair
aws ec2 create-key-pair --key-name kubernetes --output text --query 'KeyMaterial' > kubernetes.id_rsa
chmod 600 kubernetes.id_rsa

# Run controller instances
for i in 0; do
  instance_id=$(aws ec2 run-instances \
    --associate-public-ip-address \
    --image-id "$IMAGE_ID" \
    --count 1 \
    --key-name kubernetes \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --instance-type t2.large \
    --private-ip-address "10.0.1.1${i}" \
    --user-data "name=controller-${i}" \
    --subnet-id "$SUBNET_ID" \
    --block-device-mappings='{"DeviceName": "/dev/sda1", "Ebs": { "VolumeSize": 50 }, "NoDevice": "" }' \
    --output text --query 'Instances[].InstanceId')

  aws ec2 modify-instance-attribute --instance-id "$instance_id" --no-source-dest-check
  aws ec2 create-tags --resources "$instance_id" --tags "Key=Name,Value=controller-${i}"
  echo "controller-${i} created "
done

# Run worker instances
for i in 0; do
  instance_id=$(aws ec2 run-instances \
    --associate-public-ip-address \
    --image-id "$IMAGE_ID" \
    --count 1 \
    --key-name kubernetes \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --instance-type t2.xlarge \
    --private-ip-address "10.0.1.2${i}" \
    --user-data "name=worker-${i}|pod-cidr=10.200.${i}.0/24" \
    --subnet-id "$SUBNET_ID" \
    --block-device-mappings='{"DeviceName": "/dev/sda1", "Ebs": { "VolumeSize": 50 }, "NoDevice": "" }' \
    --output text --query 'Instances[].InstanceId')

  aws ec2 modify-instance-attribute --instance-id "$instance_id" --no-source-dest-check
  aws ec2 create-tags --resources "$instance_id" --tags "Key=Name,Value=worker-${i}"
  echo "worker-${i} created"
done


# chmod +x ca_setup.sh
# ./ca_setup.sh

# chmod +x configs.sh
# ./configs.sh

# chmod +x encryption.sh
# ./encryption.sh

#generate our SSH command line arguments to be able to connect to our controller instances:
for instance in controller-0; do
  external_ip=$(aws ec2 describe-instances --filters \
    "Name=tag:Name,Values=${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
echo ssh -i kubernetes.id_rsa ubuntu@$external_ip
done
for instance in worker-0; do
  external_ip=$(aws ec2 describe-instances --filters \
    "Name=tag:Name,Values=${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
echo ssh -i kubernetes.id_rsa ubuntu@$external_ip
done

# ssh -i kubernetes.id_rsa ubuntu@13.201.56.206
# ssh -i kubernetes.id_rsa ubuntu@13.232.53.204
