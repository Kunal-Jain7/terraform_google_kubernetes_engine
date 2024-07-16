output "network" {
  description = "VPC ID"
  value       = google_compute_network.client-vpc.id
}

output "subnet" {
  description = "Subnet ID"
  value       = google_compute_subnetwork.client-subnet.id
}