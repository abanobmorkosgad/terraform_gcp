resource "google_compute_region_health_check" "us-central1-autohealing" {
  name                = "autohealing-health-check"
  region              = "us-central1"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "80"
  }
}

resource "google_compute_region_health_check" "us-central2-autohealing" {
  name                = "autohealing-health-check"
  region              = "us-central2"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "80"
  }
}

resource "google_compute_region_instance_group_manager" "appserver-us-central1" {
  name = "appserver-igm"

  base_instance_name = "app"
  region             = "us-central1"

  version {
    instance_template = google_compute_region_instance_template.us-central1.self_link
  }

  named_port {
    name = "customhttp"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.us-central1-autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "foobar" {
  name   = "my-region-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.appserver-us-central1.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}


resource "google_compute_region_instance_group_manager" "appserver-us-central2" {
  name = "appserver-igm-us-central2"

  base_instance_name = "app"
  region             = "us-central2"

  version {
    instance_template = google_compute_region_instance_template.us-central2.self_link
  }

  named_port {
    name = "customhttp"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.us-central2-autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "foobar-us-central2" {
  name   = "my-region-autoscaler-us-central2"
  region = "us-central2"
  target = google_compute_region_instance_group_manager.appserver-us-central2.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}