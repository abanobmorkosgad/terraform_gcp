resource "google_dns_record_set" "frontend" {
  name = "test.abanob.com."
  type = "A"
  ttl  = 300

  managed_zone = "abanob-com"

  rrdatas = [google_compute_address.ip_address.address]
}

resource "google_certificate_manager_dns_authorization" "default" {
  name        = "dns-auth"
  location    = "global"
  description = "The default dns"
  domain      = "test.abanob.com."
}

resource "google_certificate_manager_certificate" "google-managed-cert" {
  name        = "google-managed-cert"
  description = "Global cert"
  location    = "us-central1"
  scope       = "DEFAULT"
  managed {
    domains = [
      google_certificate_manager_dns_authorization.default.domain
      ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
      ]
  }
}