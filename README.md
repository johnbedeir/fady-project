# engage-infrastructure

# Dev-Engage CareAI Infrastructure

This repository contains the Terraform configurations used to manage the infrastructure for the Dev-Engage project on (GCP). It includes the provisioning of a Kubernetes cluster, network configurations, and a PostgreSQL database instance.

## Project Structure

The infrastructure is defined across multiple Terraform files to organize resources related to networking, Kubernetes, and databases. Here's what each file does:

- `addons.tf`: Configures additional features and plugins for the Kubernetes cluster, such as Istio for service mesh capabilities and the CSI driver for enhanced storage management.
- `cluster.tf`: Defines the Google Kubernetes Engine (GKE) cluster.
- `ingress.tf`: Manages the ingress rules and configurations for accessing the services within the cluster, including setting up HTTP(S) Load Balancing as needed.
- `network.tf`: Sets up the VPC network, subnets, and a private IP range for database VPC peering.
- `outputs.tf`: Specifies output variables that provide important information about the resources.
- `provider.tf`: Configures the GCP provider with credentials and region settings.
- `sql.tf`: Manages the PostgreSQL database instance, associated database, and user configurations.
- `storage.tf`: Sets up and configures Google Cloud Filestore instances to provide managed file storage for applications that require a file system interface and a shared file system for data.
- `variables.tf`: Declares variables used across the configurations.
- `terraform.tfvars` files in Terraform provide a way to set variable values externally, enabling environment-specific configurations without altering the main code.

## Build-up Infrastructure

```
terraform init
terraform plan
terraform apply -auto-approve
```

## Post-Infrastructure

### Cluster Authentication

```
gcloud container clusters get-credentials dev-engage-careai --zone us-east1-b --project development-cloud-services
```

### Install Api-Gateway

```
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl apply -f -
```

### Install Cert-Manager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.crds.yaml
```

### Install Istio-Cni

```
helm repo add istio https://istio-release.storage.googleapis.com/charts
```

```
helm repo update
```

```
helm install istio-cni istio/cni --namespace istio-system
```

### Install gcpdisk-csi-driver

```
helm repo add mesosphere-stable https://mesosphere.github.io/charts/stable
```

```
helm repo update
```

```
helm install my-gcpdisk-csi-driver mesosphere-stable/gcpdisk-csi-driver
```

### Install Secret Store CSI Driver

```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
```

```
helm repo update
```

```
helm install secrets-store-csi-driver secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system --create-namespace --set syncSecret.enabled=true,enableSecretRotation=true,rotationPollInterval=2m
```

## Install External-DNS

```
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
```

```
helm repo update
```

```
helm install external-dns external-dns/external-dns --namespace external-dns \
  --set provider=google \
  --set google.project=johnydev \
  --set serviceAccount.name=external-dns
```

### Get the postgres password

```
terraform output -json
```

Navigate to `group_vars` and replace the value of `postgres_pass`

Get the `rwx-storage` Server IP from by running the following command:

```
kubectl get storageclass rwx-storage -o jsonpath='{.parameters.server}'
```

Copy the `server` value and navigate to `roles/engage-volumes/templates` then update it in `platform-pvc.yml.j2`

### Engage Deployment

Navigate to `vocera-engagelist-k8s` root directory and run the following command:

```
ansible-playbook eaas.yml
```

### Remove Engage

Navigate to `vocera-engagelist-k8s` root directory and run the following command:

```
ansible-playbook reset.yml
```

### Teardown Infrastructure

Navigate to `terraform-stryker-engage/terraform` root directory and run the following command:

```
terraform destroy
```
