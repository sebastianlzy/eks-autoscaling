#!/bin/bash

EKS_CLUSTER_NAME=eks-autoscaling-cluster
AWS_REGION=ap-southeast-1
ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r ".Account")

####### Create EKS Cluster
# Update EKS Cluster name
sed -e "s/EKS_CLUSTER_NAME/$EKS_CLUSTER_NAME/g" cluster-config.tmp.yaml > output/cluster-config.yaml
#eksctl create cluster -f ./output/cluster-config.yaml
#aws eks  update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME

# Display current kube config
#kubectx -c

####### Add CSI - https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/

# Update trust policy with oidc value/account number
OIDC_VALUE=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed 's~http[s]*://~~g'  | sed -r 's/([\$\.\*\/\[\\^])/\\\1/g')
sed "s/OIDC_VALUE/$OIDC_VALUE/g" ebs-iam-trust-policy.tmp.json > output/ebs-iam-trust-policy.oidc.json
sed -e "s/ACCOUNT_NUMBER/$ACCOUNT_NUMBER/g" output/ebs-iam-trust-policy.oidc.json > output/ebs-iam-trust-policy.json
rm output/ebs-iam-trust-policy.oidc.json

#Create IAM policy for EBS CSI Driver
aws iam create-policy --policy-name AmazonEKS_EBS_CSI_Driver_Policy --policy-document file://ebs-iam-policy.json

# Create IAM role with Trust Policy
aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://./output/ebs-iam-trust-policy.json

# Attach your new IAM policy to the role:
aws iam attach-role-policy \
--policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/AmazonEKS_EBS_CSI_Driver_Policy \
--role-name AmazonEKS_EBS_CSI_DriverRole

# Deploy Amazon EBS CSI
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Annotate the ebs-csi-controller-sa Kubernetes service account with the Amazon Resource Name (ARN) of the IAM role that you created earlier
kubectl annotate serviceaccount ebs-csi-controller-sa \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_NUMBER:role/AmazonEKS_EBS_CSI_DriverRole

# Replace the driver pods
kubectl delete pods \
  -n kube-system \
  -l=app=ebs-csi-controller