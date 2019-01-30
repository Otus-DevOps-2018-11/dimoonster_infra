resource "google_compute_instance" "db" {
  count        = "${var.inst_count}"
  name         = "${var.vm_name}-db-node-${count.index}"
  machine_type = "g1-small"
  zone         = "${local.vm_zone}"
  tags         = ["reddit-app", "reddit-db"]

  # загрузочный диск
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  # сеть
  network_interface {
    network       = "default"
    access_config = {}
  }

  # метаданные
  metadata {
    ssh-keys               = "appuser:${file(var.public_key_path)}"
    block-project-ssh-keys = false
  }

#   connection {
#     type        = "ssh"
#     user        = "appuser"
#     agent       = "false"
#     private_key = "${file(var.private_key_path)}"
#   }

#   provisioner "file" {
#     source      = "files/reddit.service"
#     destination = "/tmp/reddit.service"
#   }

#   provisioner "remote-exec" {
#     script = "files/deploy.sh"
#   }
}

resource "google_compute_firewall" "firewall_reddit_db_app" {
  name    = "allow-mongo-for-reddit-app"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_tags = ["reddit-app"]
  target_tags   = ["reddit-db"]
}
