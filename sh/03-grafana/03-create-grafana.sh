#!/bin/zsh

# Create namespace
kubectl create namespace grafana

# Deploy Grafana
helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values $PWD/grafana.yaml \
    --set service.type=LoadBalancer

# Get your 'admin' user password by running:
# kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
# grafana.grafana.svc.cluster.local

# export SERVICE_IP=$(kubectl get svc --namespace grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
# Login with the password from step 1 and the username: admin

# echo $SERVICE_IP