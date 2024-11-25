# resource "google_sql_database_instance" "postgres" {
#   name               = "${var.environment_name}-${var.cluster_name}-${var.cloudsql_instance_name}"
#   region             = var.region
#   database_version   = var.cloudsql_database_version
#   deletion_protection = false  // Ensure this is set correctly

#   settings {
#     tier = var.cloudsql_instance_type

#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = var.vpc_name
#     }
#   }

#   depends_on = [
#     google_service_networking_connection.private_vpc_connection
#   ]
# }

# resource "google_sql_database" "default" {
#   name     = var.cloudsql_database_name
#   instance = google_sql_database_instance.postgres.name
# }

# resource "google_sql_user" "default" {
#   name     = var.database_username
#   instance = google_sql_database_instance.postgres.name
#   password = random_password.password.result
# }

# resource "random_password" "password" {
#   length  = 16
#   special = true
# }
