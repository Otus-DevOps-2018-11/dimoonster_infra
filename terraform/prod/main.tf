provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

# resource "google_compute_project_metadata" "ssh_keys" {
#   metadata {
#     ssh-keys = <<EOF
#     appuser1:${file(var.public_key_path)}
#     appuser2:${file(var.public_key_path)}
# EOF
#   }
# }

module "app" {
  source = "../modules/app"
  region = "${var.region}"
  vm_zone = "${local.vm_zone}"
  public_key_path = "${var.public_key_path}"
  vm_name = "${var.vm_name}"
  inst_count = "1"
  app_disk_image = "${var.app_disk_image}"
}

module "db" {
  source = "../modules/db"
  region = "${var.region}"
  vm_zone = "${local.vm_zone}"
  public_key_path = "${var.public_key_path}"
  vm_name = "${var.vm_name}"
  inst_count = "1"
  db_disk_image = "${var.db_disk_image}"  
}

module "vpc" {
  source = "../modules/vpc"
  source_ranges = ["95.161.165.243/32"]
}
