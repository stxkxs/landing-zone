output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster API server"
  value       = "https://${google_container_cluster.this.endpoint}"
}

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate authority data for the cluster"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
}

output "workload_identity_pool" {
  description = "The Workload Identity pool for the cluster"
  value       = google_container_cluster.this.workload_identity_config[0].workload_pool
}
