################################################################################
# Storage
################################################################################

resource "google_filestore_instance" "my_nfs" {
  name    = "${var.environment}-${var.name_prefix}-${var.filestore_name}"
  tier    = "STANDARD"  # or "PREMIUM" for better performance
  location = random_shuffle.zone.result[0]

  file_shares {
    name       = "nfsshare"
    capacity_gb = 1024  # Define size based on needs
    
    nfs_export_options {
        access_mode = "READ_WRITE"
        squash_mode = "NO_ROOT_SQUASH"
        ip_ranges   = ["10.0.2.0/24"]   # Use your GKE node CIDR range to give permission to the deployed services on the nodes for accessing the filestore
    }
  }

  networks {
    network = google_compute_network.vpc_network.name
    modes   = ["MODE_IPV4"]
  }
}

resource "kubernetes_storage_class" "rwx_storage" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner = "nfs.csi.k8s.io"  # You would need an NFS client provisioner set up in the cluster
  reclaim_policy      = "Delete"
  allow_volume_expansion = true

  parameters = {
    server = google_filestore_instance.my_nfs.networks[0].ip_addresses[0]
    path   = var.filestore_path
  }
}

