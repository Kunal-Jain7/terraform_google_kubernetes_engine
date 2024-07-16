resource "google_storage_bucket" "client-bucket" {
  name          = format("client-bucket-%s", var.stack_env)
  storage_class = var.storage_class
  location      = var.location

}