variable "project" {
  description = "Project ID"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "vm_zone" {
  description = "Zone to start vm"
  default     = ""
}

locals {
  default_vm_zone = "${var.region}-b"
  vm_zone         = "${var.vm_zone != "" ? var.vm_zone : local.default_vm_zone}"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  description = "Path to the private key used by provisioners"
}

variable "disk_image" {
  description = "Disk image"
}

variable "vm_name" {
  description = "Name of Virtual Machine"
}

variable "inst_count" {
  description = "Instances count"
  default     = "1"
}

variable "app_disk_image" {
  description = "Disk image for application"
  default     = "reddit-app"
}

variable "db_disk_image" {
  description = "Disk image for application db"
  default     = "reddit-db"
}
