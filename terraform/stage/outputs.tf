output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_external_ip" {
  value = "${module.db.external_ip}"
}

output "db_internal_ip" {
  value = "${module.db.internal_ip}"
}

# output "app-lb-ip" {
#   value = "${google_compute_forwarding_rule.http.ip_address}"
# }
