output "gke_cluster_name" {
  description = "The details of the gke cluster"
  value       = google_container_cluster.application-kubernetes-cluster.name
}

output "gke_node_pools" {
  value = google_container_node_pool.app_cluster_linux_node_pool.id
}