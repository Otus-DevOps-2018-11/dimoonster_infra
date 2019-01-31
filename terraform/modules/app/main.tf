resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_instance" "app" {
  count        = "${var.inst_count}"
  name         = "${var.vm_name}-app-node-${count.index}"
  machine_type = "g1-small"
  zone         = "${local.vm_zone}"
  tags         = ["reddit-app"]

  depends_on = ["google_compute_address.app_ip"]

  # загрузочный диск
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  # сеть
  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
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
#     source      = "../modules/app/files/reddit.service"
#     destination = "/tmp/reddit.service"
#   }

#   provisioner "file" {
#     source      = "../modules/app/files/deploy.sh"
#     destination = "/tmp/deploy.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/deploy.sh",
#       "IP=${var.db_ip_addr} /tmp/deploy.sh",
#     ]
#   }
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
