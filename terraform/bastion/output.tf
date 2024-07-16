output "bastion_ip" {
  value = google_compute_instance.gke-bastion-host.network_interface.0.network_ip
}

output "ssh" {
  value = "gcloud compute ssh ${google_compute_instance.gke-bastion-host.name} --project ${var.project_id} --zone ${google_compute_instance.gke-bastion-host.zone} -- -L8888:127.0.0.1:8888"
}

output "kubectl_command" {
  value = "HTTPS_PROXY=localhost:8888 kubectl"
}