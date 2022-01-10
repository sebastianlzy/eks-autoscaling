#!/bin/zsh

# https://www.eksworkshop.com/advanced/330_servicemesh_using_appmesh/integrate_observability/prometheus_metrics/

# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts

kubectl create namespace prometheus

# Display current namespace
# kubens -c

# We will use gp2 EBS volumes for simplicity and demonstration purpose.
# When deploying in production, you would use io2 volumes with desired IOPS
# and increase the default storage size in the manifests to get better performance.

helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"


# The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
# prometheus-server.prometheus.svc.cluster.local

# Get the Prometheus server URL by running these commands in the same shell:
#  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
#  kubectl --namespace prometheus port-forward $POD_NAME 9090

# The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
# prometheus-alertmanager.prometheus.svc.cluster.local

# Get the Alertmanager URL by running these commands in the same shell:
# export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
# kubectl --namespace prometheus port-forward $POD_NAME 9093


