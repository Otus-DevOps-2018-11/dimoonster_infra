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

resource "google_compute_instance" "app" {
  count = "${var.inst_count}"
  name         = "${var.vm_name}-node-${count.index}"
  machine_type = "g1-small"
  zone         = "${local.vm_zone}"
  tags         = ["reddit-app"]


  # загрузочный диск
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # сеть
  network_interface {
    network       = "default"
    access_config = {}
  }

  # метаданные
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
    block-project-ssh-keys = false
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = "false"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/reddit.service"
    destination = "/tmp/reddit.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_reddit_app" {
  name    = "allow-reddit-app-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
