#!/bin/bash

# Variables
project_id="johnydev"
service_account_email="terraform-sa@${project_id}.iam.gserviceaccount.com"
key_ids=$(gcloud iam service-accounts keys list --iam-account=$service_account_email --format="value(name)")
filename="gcp-credentials.json"
cert-manager="https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.crds.yaml"
api-gateway="github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0"
istio-cni-chart="https://istio-release.storage.googleapis.com/charts"
csi-driver-chart="https://mesosphere.github.io/charts/stable"
secret-store-csi-driver-chart="https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
istio-namespace="istio-system"
zone="$(terraform output -raw cluster_zone)"
cluster_name="$(terraform output -raw cluster_name)"
End of Variables

# Update helm repos
helm repo update

# echo "--------------------GCP Login--------------------"
# gcloud auth login

# # Check if there are any keys to delete
# if [ -z "$key_ids" ]; then
#     echo "No keys found for service account: $service_account_email"
#     exit 0
# fi

# # Loop through each key ID and delete the key
# for key_id in $key_ids; do
#     echo "Deleting key $key_id for service account: $service_account_email"
#     gcloud iam service-accounts keys delete $key_id --iam-account=$service_account_email --quiet
# done

# # Get GCP credentials
# echo "--------------------Get Credentials--------------------"
# gcloud iam service-accounts keys create ${filename} --iam-account ${service_account_email}

# echo "--------------------Building Infrastructure------------"
# cd terraform-engage-gcp && \ 
# terraform init 
# tf plan
# terraform apply -auto-approve
# cd ..

# echo "--------------------Wait before updating kubeconfig--------------------"
# sleep 60s

# echo "--------------------Update Kubeconfig--------------------"
# gcloud container clusters get-credentials ${cluster_name} --zone ${zone} --project ${project_id}

# echo "--------------------Deploy Api-Gateway--------------------"
# kubectl kustomize "${api-gateway}" | kubectl apply -f -

# echo "--------------------Deploy Cert-Manager--------------------"
# kubectl apply -f ${cert-manager}


# echo "--------------------Addons Istio CNI--------------------"
# echo "--------------------Addons CSI Driver--------------------"
# echo "--------------------Addons Seccret Store CSI Driver--------------------"
# helm repo add istio ${istio-cni-chart}
# helm repo add mesosphere-stable ${csi-driver-chart}
# helm repo add secrets-store-csi-driver ${secret-store-csi-driver-chart}
# helm repo update
# helm install istio-cni istio/cni --namespace ${istio-namespace}
helm install my-gcpdisk-csi-driver mesosphere-stable/gcpdisk-csi-driver
helm install secrets-store-csi-driver secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system --create-namespace --set syncSecret.enabled=true,enableSecretRotation=true,rotationPollInterval=2m