
################################################################################
# GCP Configuration Variables - provider.tf
################################################################################

variable "gcp_credentials_file" {
  description = "Path to the Google Cloud Platform service account credentials file"
  type        = string
  default     = "gcp-credentials.json"
}

variable "region" {
  default = "us-east1"
}

# variable "zone" {
#   default = "us-east1-b"
# }

variable "project_id" {
  default = "johnydev"
}

variable "environment" {
  type        = string
  default     = "dev"
}

################################################################################
# GKE Cluster Configurations Variables - cluster.tf
################################################################################

variable "name_prefix" {
  type        = string
  default     = "engage-careai"
}


variable "cluster_cidr" {
  type        = string
  default     = "10.0.8.0/21"
}

variable "services_cidr" {
  type        = string
  default     = "10.0.16.0/22"
}

variable "cluster_cidr_block" {
  type        = string
  default     = "0.0.0.0/0"
}

# variable "nodepool_name" {
#   type        = string
#   default     = "nodepool"
# }

variable "node_machine_type" {
  type        = string
  default     = "e2-medium"
}

variable "node_disk_type" {
  type        = string
  default     = "pd-standard"
}

variable "node_disk_size" {
  default     = 100
}

variable "initial_node_number" {
  default     = 3
}

variable "min_nodes_number" {
  default     = 3
}

variable "max_nodes_number" {
  default     = 5
}

################################################################################
# Network Configurations Variables - network.tf
################################################################################

# variable "vpc_name" {
#   type        = string
#   default     = "projects/${var.project_id}/global/networks/dev-vpc-hl7"
# }

# variable "subnet" {
#   type        = string
#   default     = "projects/${var.project_id}/regions/us-east1/subnetworks/dev-subnet-engage"
# }

# variable "subnet_name" {
#   type        = string
#   default     = "engage-subnet"
# }

# variable "private_ip_name" {
#   type        = string
#   default     = "postgres-private-ip"
# }

variable "efs_firewall_ingress_name" {
  type        = string
  default     = "allow-nfs-tcp"
}

variable "efs_firewall_egress_name" {
  type        = string
  default     = "allow-nfs-all"
}

variable "firewall_ingress_source_ranges" {
  description = "List of IP CIDR ranges allowed access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "firewall_egress_source_ranges" {
  description = "List of IP CIDR ranges allowed access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

################################################################################
# Storage Configurations Variables - storage.tf
################################################################################

variable "filestore_name" {
  type        = string
  default     = "filestore"
}

variable "csi_storage_class_name" {
  type        = string
  default     = "pd-csi"
}

variable "filestore_path" {
  type        = string
  default     = "/nfsshare"
}

variable "storage_class_name" {
  type        = string
  default     = "rwx-storage"
}

################################################################################
# Ingress Configurations Variables - ingress.tf
################################################################################

variable "ingress_name" {
  type        = string
  default     = "nginx-ingress"
}

variable "ingress_chart_name" {
  type        = string
  default     = "ingress-nginx"
}

variable "kube_namespace" {
  type        = string
  default     = "kube-system"
}

################################################################################
# Cluster Plugins Variables - addons.tf
################################################################################

variable "coredns_name" {
  type        = string
  default     = "coredns"
}

variable "istio_base_name" {
  type        = string
  default     = "istio-base"
}

variable "istiod_name" {
  type        = string
  default     = "istiod"
}

variable "istio_namesppace" {
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  description = "istio version"
  type        = string
  default     = "1.20.4"
}

variable "secrets_store_csi_version" {
  description = "Version of the Secrets Store CSI Driver Helm chart"
  type        = string
  default     = "0.0.20"  
}

################################################################################
# Cloud SQL Variables - sql.tf
################################################################################

# variable "cloudsql_instance_name" {
#   type        = string
#   default     = "engage-psql"
# }

# variable "cloudsql_database_version" {
#   type        = string
#   default     = "POSTGRES_14"
# }

# variable "cloudsql_instance_type" {
#   type        = string
#   default     = "db-f1-micro"
# }

# variable "cloudsql_database_name" {
#   type        = string
#   default     = "default"
# }

# variable "database_username" {
#   type        = string
# // store it in tfvars file
# }