locals {
  stack_env = terraform.workspace
  location = lookup(
    var.location,
    terraform.workspace,
    var.location[var.default_value],
  )
  storage_class = lookup(
    var.storage_class,
    terraform.workspace,
    var.storage_class[var.default_value],
  )
  subnetwork_range = lookup(
    var.subnetwork_range,
    terraform.workspace,
    var.subnetwork_range[var.default_value],
  )
  subnetwork_services = lookup(
    var.subnetwork_services,
    terraform.workspace,
    var.subnetwork_services[var.default_value],
  )
  subnetwork_pods = lookup(
    var.subnetwork_pods,
    terraform.workspace,
    var.subnetwork_pods[var.default_value],
  )
  project_id = lookup(
    var.project_id,
    terraform.workspace,
    var.project_id[var.default_value],
  )
  service_account = lookup(
    var.service_account,
    terraform.workspace,
    var.service_account[var.default_value],
  )
  cluster_master_ip_cidr_range = lookup(
    var.cluster_master_ip_cidr_range,
    terraform.workspace,
    var.cluster_master_ip_cidr_range[var.default_value],
  )
}

variable "default_value" {
  description = "This will be the default value defined for each variable"
  default     = "default"
}

variable "location" {
  type = map(string)
  default = {
    prod    = "us-central1"
    preprod = "us-central1"
    default = "us-central1"
  }
}

variable "storage_class" {
  type = map(string)
  default = {
    prod    = "STANDARD"
    preprod = "STANDARD"
    default = "STANDARD"
  }
}

variable "subnetwork_range" {
  type = map(string)
  default = {
    prod    = "10.10.0.0/18"
    preprod = "10.10.0.0/17"
    default = "10.10.0.0/16"
  }
}

variable "subnetwork_services" {
  type = map(string)
  default = {
    prod    = "10.102.0.0/18"
    preprod = "10.102.0.0/17"
    default = "10.102.0.0/16"
  }
}

variable "subnetwork_pods" {
  type = map(string)
  default = {
    prod    = "10.101.0.0/18"
    preprod = "10.101.0.0/17"
    default = "10.90.0.0/16"
  }
}

variable "project_id" {
  type = map(string)
  default = {
    prod    = "terraform-gcp-429515"
    preprod = "terraform-gcp-429515"
    default = "terraform-gcp-429515"
  }
}

variable "service_account" {
  type = map(string)
  default = {
    prod    = ""
    preprod = ""
    default = "svc-terraform-gcp@terraform-gcp-429515.iam.gserviceaccount.com"
  }
}

variable "cluster_master_ip_cidr_range" {
  type = map(string)
  default = {
    prod    = ""
    preprod = ""
    default = "10.100.100.0/28"
  }
}