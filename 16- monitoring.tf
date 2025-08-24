resource "google_compute_address" "ip_address" {
  name   = "my-address"
  region = "us-central1"
}


resource "google_monitoring_notification_channel" "basic" {
  display_name = "Test Notification Channel"
  type         = "email"
  labels = {
    email_address = "abanob.morkos13@gmail.com"
  }
}

resource "google_monitoring_uptime_check_config" "https" {
  display_name = "https-uptime-check"
  timeout = "60s"

  http_check {
    path = "/index.html"
    port = "443"
    use_ssl = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = "my-project-name"
      host = google_compute_address.ip_address.address
    }
  }

  content_matchers {
    content = "welcome to my website"
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "My Alert Policy"
  combiner     = "OR"
  conditions {
    display_name = "test condition"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      duration   = "0s"
      comparison = "COMPARISON_LT"
      threshold_value = 1
    }
  }

  documentation {
    content = "This is a test alert policy"
    mime_type = "text/markdown"
  }
  
  notification_channels = [google_monitoring_notification_channel.basic.id]
}