terraform {
  backend "gcs" {
    bucket = "terraform-devops-gke-statefile"
    prefix = "terraform/gke/"
  }
}

module "storage" {

  source        = "./storage"
  stack_env     = local.stack_env
  location      = local.location
  storage_class = local.storage_class

}

module "networking" {
  source = "./networking"

  stack_env           = local.stack_env
  region              = local.location
  subnetwork_range    = local.subnetwork_range
  subnetwork_pods     = local.subnetwork_pods
  subnetwork_services = local.subnetwork_services
}

module "kubernetes-cluster" {
  source     = "./kubernetes-cluster"
  depends_on = [module.bastion]

  stack_env                  = local.stack_env
  region                     = local.location
  project_id                 = local.project_id
  service_account            = local.service_account
  network_name               = module.networking.network
  subnet_name                = module.networking.subnet
  master_ipv4_cidr_block     = local.cluster_master_ip_cidr_range
  pods_ipv4_cidr_block       = local.subnetwork_pods
  services_ipv4_cidr_block   = local.subnetwork_services
  authorized_ipv4_cidr_block = "${module.bastion.bastion_ip}/32"
}

module "bastion" {
  source = "./bastion"

  project_id   = local.project_id
  region       = local.location
  network_name = module.networking.network
  subnet_name  = module.networking.subnet
  stack_env    = local.stack_env
}
