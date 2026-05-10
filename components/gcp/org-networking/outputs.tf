output "shared_vpc_network_id" {
  description = "The ID of the Shared VPC network"
  value       = var.enable_shared_vpc ? google_compute_network.shared_vpc[0].id : ""
}
