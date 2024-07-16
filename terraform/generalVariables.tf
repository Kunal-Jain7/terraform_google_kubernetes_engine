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
}

variable "default_value" {
  description = "This will be the default value defined for each variable"
  default     = "default"
}

variable "location" {
  type = map(string)
  default = {
    prod    = "US-EAST1"
    preprod = "US-WEST1"
    default = "US-CENTRAL1"
  }
}

variable "storage_class" {
  type = map(string)
  default = {
    prod    = "REGIONAL"
    preprod = "COLDLINE"
    default = "STANDARD"
  }
}