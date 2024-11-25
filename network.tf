# ################################################################################
# # Network Configuration
# ################################################################################

# resource "google_compute_subnetwork" "dev_subnet_engage" {
#   name          = "${var.environment_name}-${var.cluster_name}-${var.subnet_name}"
#   ip_cidr_range = "10.24.0.0/20"
#   region        = var.region
#   network       = var.vpc_name
# }
# resource "google_compute_global_address" "private_ip_range" {
#   name          = "${var.environment_name}-${var.cluster_name}-${var.private_ip_name}"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = var.vpc_name
# }

# resource "google_service_networking_connection" "private_vpc_connection" {
#   network       = var.vpc_name
#   service       = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
# }

# ################################################################################
# # Firewall Configuration
# ################################################################################

# # To allow the Services that will be deployed on the nodes access to the filestore
# resource "google_compute_firewall" "gke_efs_ingress" {
#   name    = "${var.environment_name}-${var.cluster_name}-${var.efs_firewall_ingress_name}"
#   network = var.vpc_name

#   allow {
#     protocol = "tcp"
#     ports    = ["2049"]
#   }

#   source_ranges = var.firewall_ingress_source_ranges
#   target_tags   = ["gke-node"]      # Replace with appropriate network tags for GKE nodes if required
# }

# resource "google_compute_firewall" "gke_efs_egress" {
#   name    = "${var.environment_name}-${var.cluster_name}-${var.efs_firewall_egress_name}"
#   network = var.vpc_name

#   allow {
#     protocol = "all"
#   }

#   source_ranges  = var.firewall_egress_source_ranges
#   target_tags    = ["gke-node"]
# }