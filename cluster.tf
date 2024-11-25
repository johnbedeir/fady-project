# resource "google_project_iam_member" "k8s_admin" {
#   role   = "roles/container.admin"
#   member = "user:your-email@example.com" # Replace with your admin email
# }

################################################################################
# Cluster Configuration
################################################################################

data "google_compute_zones" "available" {
  region = var.region
}

resource "random_shuffle" "zone" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "google_container_cluster" "primary" {
  name                     = "${var.environment}-${var.name_prefix}"
  location                 = random_shuffle.zone.result[0]
  remove_default_node_pool = true
  initial_node_count       = var.initial_node_number

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.private_subnet.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_cidr
    services_ipv4_cidr_block = var.services_cidr
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = true
    }
    // Properly configuring DNS cache if necessary
    dns_cache_config {
      enabled = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.cluster_cidr_block
      display_name = "All"
    }
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

################################################################################
# NodePool Configuration
################################################################################

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.environment}-${var.name_prefix}-nodepool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.initial_node_number

  node_config {
    preemptible  = false
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    tags = ["gke-node", "private-subnet"]
  }

  autoscaling {
    min_node_count = var.min_nodes_number
    max_node_count = var.max_nodes_number
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.36.0"

  set {
    name  = "cloudProvider"
    value = "gce"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  // GKE-specific settings
  set {
    name  = "autoDiscovery.clusterName"
    value = "${var.name_prefix}-${var.environment}"
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.scale-down-enabled"
    value = "true"
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "5m"
  }
}

