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
/*
module "networking" {
  source = "./networking"

  stack_env = local.stack_env

}
*/