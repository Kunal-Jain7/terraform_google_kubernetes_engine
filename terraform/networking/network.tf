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
  /*
  secondary_ip_range {
    range_name    = "gke-pods-1"
    ip_cidr_range = var.subnetwork_pods
  }

  secondary_ip_range {
    range_name    = "gke-services-1"
    ip_cidr_range = var.subnetwork_services
  }*/
}

resource "google_compute_route" "egress_internet" {
  name             = format("client-rt-%s", var.stack_env)
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.client-vpc.id
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_router" "client-router" {
  network = google_compute_network.client-vpc.id
  region  = google_compute_subnetwork.client-subnet.region
  name    = format("client-router-%s", var.stack_env)
}

resource "google_compute_router_nat" "client-router-nat" {
  name                               = format("client-router-%s", var.stack_env)
  router                             = google_compute_router.client-router.name
  region                             = google_compute_subnetwork.client-subnet.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.client-subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}