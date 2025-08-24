resource "google_compute_address" "ip_address" {
  name   = "my-address"
  region = "us-central1"
}

resource "google_compute_region_backend_service" "appserver" {
  name                  = "region-service"
  protocol              = "http"
  region                = "us-central1"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.autohealing.self_link]
  backend {
    group           = google_compute_region_instance_group_manager.appserver.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
}

resource "google_compute_region_backend_service" "appserver2" {
  name                  = "region-service"
  protocol              = "http"
  region                = "us-central1"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.autohealing.self_link]
  backend {
    group           = google_compute_region_instance_group_manager.appserver2.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
}

resource "google_compute_region_url_map" "regionurlmap" {
  name            = "mylb"
  region          = "us-central1"
  default_service = google_compute_region_backend_service.appserver.id
  host_rule {
    hosts = [ "*" ]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = google_compute_region_backend_service.appserver.id
    
    route_rules {
      priority = 1
      service = google_compute_region_backend_service.appserver.id
      match_rules {
        prefix_match = "/"
        ignore_case = true 
        header_matches {
          header_name = "appserver"
          exact_match = "app1"
        }
      }
    }
    
    route_rules {
      priority = 2
      service = google_compute_region_backend_service.appserver2.id
      match_rules {
        prefix_match = "/"
        ignore_case = true 
        header_matches {
          header_name = "appserver"
          exact_match = "app2"
        }
      }
    }
  }
}

resource "google_compute_region_target_http_proxy" "default" {
  region  = "us-central1"
  name    = "test-proxy"
  url_map = google_compute_region_url_map.regionurlmap.id
}

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  region                = "us-central1"
  depends_on            = [google_compute_subnetwork.proxy_only_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.proxy_only_subnet.id
  network_tier          = "PREMIUM"
  ip_address            = google_compute_address.ip_address.address
}