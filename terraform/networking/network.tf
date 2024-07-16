resource "google_compute_network" "client-vpc" {
  name                    = format("client-vpc-%s", var.stack_env)
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "client-subnet" {
  network                  = google_compute_network.client-vpc.id
  name                     = format("client-subnet-%s", var.stack_env)
  region                   = var.region
  ip_cidr_range            = var.subnetwork_range
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-1"
    ip_cidr_range = var.subnetwork_pods
  }

  secondary_ip_range {
    range_name    = "gke-services-1"
    ip_cidr_range = var.subnetwork_services
  }
}