resource "google_container_cluster" "application-kubernetes-cluster" {
  name                     = format("%s-application-kubernetes-cluster", var.stack_env)
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  network    = var.network_name
  subnetwork = var.subnet_name

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  release_channel {
    channel = "STABLE"
  }

  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
      disabled = false
    }
  }

  /* Enable network policy configurations (like Calico).
  For some reason this has to be in here twice. */
  network_policy {
    enabled = "true"
  }

  workload_identity_config {
    workload_pool = format("%s.svc.id.goog", var.project_id)
  }
}

resource "google_container_node_pool" "app_cluster_linux_node_pool" {
  name       = format("%s-application-node-pool", var.stack_env)
  location   = "us-central1-a"
  cluster    = google_container_cluster.application-kubernetes-cluster.name
  node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 2
  }

  max_pods_per_node = 100

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    disk_size_gb = 25

    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = google_container_cluster.application-kubernetes-cluster.name
    }

    shielded_instance_config {
      enable_secure_boot = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      google-compute-enable-virtio-rng = "true"
      disable-legacy-endpoints         = "true"
    }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 1
  }
}