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
