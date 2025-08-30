resource "google_compute_global_address" "ip_address" {
  name   = "my-address"
}

resource "google_compute_backend_service" "default" {
  name                  = "region-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.us-central1-autohealing.self_link]
  backend {
    group           = google_compute_region_instance_group_manager.appserver-us-central1.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
  backend {
    group           = google_compute_region_instance_group_manager.appserver-us-central2.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
}

resource "google_compute_url_map" "regionurlmap" {
  name            = "mylb"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "test-proxy"
  url_map = google_compute_url_map.regionurlmap.id
}

resource "google_compute_forwarding_rule" "test_google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.ip_address.address
}
