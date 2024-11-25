################################################################################
# Cluster Plugins
################################################################################

# CoreDNS is managed by GKE, but you can customize it using Kubernetes resources if needed
resource "kubernetes_storage_class" "pd_csi" {
  metadata {
    name = var.csi_storage_class_name
  }
  storage_provisioner = "pd.csi.storage.gke.io"  # Correct argument name
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_config_map" "coredns" {
  metadata {
    name      = var.coredns_name
    namespace = var.kube_namespace
  }
  data = {
    Corefile = <<-EOF
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    EOF
  }
}

resource "helm_release" "istio_base" {
  name             = var.istio_base_name
  namespace        = var.istio_namesppace
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.istio_version
  create_namespace = true
}

resource "helm_release" "istiod" {
  name             = var.istiod_name
  namespace        = var.istio_namesppace
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = var.istiod_name
  version          = var.istio_version
  set {
    name  = "pilot.cni.enabled"
    value = "true"
  }
}

# Namespace for ExternalDNS
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

# Service Account for ExternalDNS
resource "google_service_account" "external_dns" {
  account_id   = "external-dns"
  display_name = "External DNS Service Account"
}

# IAM Permissions for ExternalDNS
resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

# Service Account Key
resource "google_service_account_key" "external_dns_key" {
  service_account_id = google_service_account.external_dns.name
}

# Kubernetes Secret for ExternalDNS Key
resource "kubernetes_secret" "external_dns_secret" {
  metadata {
    name      = "external-dns-secret"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    "credentials.json" = base64encode(google_service_account_key.external_dns_key.private_key)
  }
}

# Helm Release for ExternalDNS
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = kubernetes_namespace.external_dns.metadata[0].name
  version          = "1.7.1" # Update to the desired version
  create_namespace = false

  set {
    name  = "provider"
    value = "google"
  }

  set {
    name  = "google.project"
    value = var.project_id
  }

  set {
    name  = "domainFilters[0]"
    value = "example.com" # Replace with your managed domain
  }

  set {
    name  = "extraArgs[0]"
    value = "--policy=sync"
  }

  set {
    name  = "extraArgs[1]"
    value = "--log-level=debug"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = google_service_account.external_dns.account_id
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "volumeMounts[0].name"
    value = "credentials"
  }

  set {
    name  = "volumeMounts[0].mountPath"
    value = "/etc/kubernetes"
  }

  set {
    name  = "volumes[0].name"
    value = "credentials"
  }

  set {
    name  = "volumes[0].secret.secretName"
    value = kubernetes_secret.external_dns_secret.metadata[0].name
  }
}