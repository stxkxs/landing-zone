output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.this.name
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [google_compute_subnetwork.private.id]
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [google_compute_subnetwork.public.id]
}
