resource "google_compute_address" "external_ip" {
  name = "${var.environment}-${var.name_prefix}-external-ip"
}


resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.environment}-${var.name_prefix}-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.self_link

  // Enables VMs in this subnet to be assigned public IPs
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.environment}-${var.name_prefix}-private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc_network.self_link

  // Ensures VMs in this subnet cannot be assigned public IPs
  private_ip_google_access = true
}

################################################################################
# Firewall Configuration
################################################################################

# To allow the Services that will be deployed on the nodes access to the filestore
resource "google_compute_firewall" "gke_efs_ingress" {
  name    = "${var.environment}-${var.name_prefix}-${var.efs_firewall_ingress_name}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["2049"]
  }

  source_ranges = var.firewall_ingress_source_ranges
  target_tags   = ["gke-node"]      # Replace with appropriate network tags for GKE nodes if required
}

resource "google_compute_firewall" "gke_efs_egress" {
  name    = "${var.environment}-${var.name_prefix}-${var.efs_firewall_egress_name}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "all"
  }

  source_ranges  = var.firewall_egress_source_ranges
  target_tags    = ["gke-node"]
}