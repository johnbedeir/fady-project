################################################################################
# GKE Outputs
################################################################################

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_zone" {
  value = google_container_cluster.primary.location
}

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster"
}

################################################################################
# Cloud SQL Outputs
################################################################################

# output "postgres_instance_name" {
#   value = google_sql_database_instance.postgres.name
# }

# output "postgres_instance_connection_name" {
#   value = google_sql_database_instance.postgres.connection_name
# }

# output "postgres_user" {
#   value = google_sql_user.default.name
# }

# output "postgres_password" {
#   value = google_sql_user.default.password
#   sensitive = true
# }

# output "kubernetes_storage_class_name" {
#   value = kubernetes_storage_class.rwx_storage.metadata[0].name
#   description = "The name of the Kubernetes storage class for dynamic volume provisioning."
# }

# output "db_username" {
#   value       = var.db_username // store it locally in tfvars file
#   description = "The database username"
# }

# output "cloudsql_public_ip" {
#   value = google_sql_database_instance.postgres.public_ip_address
# }

