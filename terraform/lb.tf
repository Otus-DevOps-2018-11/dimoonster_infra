resource "google_compute_address" "app-addr" {
  name = "app-www-address"
}

resource "google_compute_target_pool" "app-targets" {
  name = "app-www-target-pool"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = ["${google_compute_http_health_check.app-check.name}"]
}

resource "google_compute_http_health_check" "app-check" {
  name                = "app-www-check"
  request_path        = "/"
  check_interval_sec  = 1
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 1
  port                = "9292"
}

resource "google_compute_forwarding_rule" "http" {
  name       = "app-www-http-forwarding-rule"
  target     = "${google_compute_target_pool.app-targets.self_link}"
  ip_address = "${google_compute_address.app-addr.address}"
  port_range = "9292"
}
