resource "google_compute_region_url_map" "http_to_https_url_map" {
  name            = "http-to-https-url-map"
  region          = "us-central1"
  default_url_redirect {
    https_redirect = true 
    strip_query    = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_region_target_http_proxy" "http_to_https_http_proxy" {
  region  = "us-central1"
  name    = "http-to-https-http-proxy"
  url_map = google_compute_region_url_map.http_to_https_url_map.id
}

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  region                = "us-central1"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.http_to_https_http_proxy.id
  network               = google_compute_network.vpc.id
  network_tier          = "PREMIUM"
  ip_address            = google_compute_global_address.ip_address.address
}