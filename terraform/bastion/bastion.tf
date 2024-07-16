locals {
  hostname = format("%s-gke-bastion-host", var.stack_env)
}

resource "google_service_account" "gke-bastion-serviceaccount" {
  account_id   = format("%s-bastion-sa", var.stack_env)
  display_name = format("%s-gke-bastion-serviceaccount", var.stack_env)
}

resource "google_compute_firewall" "bastion-ssh" {
  name          = format("%s-bastion-ssh-rule", var.stack_env)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  target_tags = ["gke-bastion-host"]
}


resource "google_compute_instance" "gke-bastion-host" {
  name         = local.hostname
  machine_type = "e2-medium"
  project      = var.project_id
  tags         = ["gke-bastion-host"]
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata_startup_script = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  sudo apt-get update -y
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
  sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
  EOF

  network_interface {
    subnetwork = var.subnet_name

    access_config {
      network_tier = "STANDARD"
    }
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.gke-bastion-serviceaccount.email
    scopes = ["cloud-platform"]
  }

  provisioner "local-exec" {
    command = <<EOF
        READY=""
        for i in $(seq 1 20); do
          if gcloud compute ssh ${local.hostname} --project ${var.project_id} --zone ${var.region}-a --command uptime; then
            READY="yes"
            break;
          fi
          echo "Waiting for ${local.hostname} to initialize..."
          sleep 10;
        done
        if [[ -z $READY ]]; then
          echo "${local.hostname} failed to start in time."
          echo "Please verify that the instance starts and then re-run `terraform apply`"
          exit 1
        fi
EOF
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

