# Example: Deploy static website to GCS using GitHub Actions with Workload Identity
# This demonstrates a complete GCS deployment using keyless authentication

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Data source to get project information
data "google_project" "project" {
  project_id = var.project_id
}

# GCS bucket for static website hosting
resource "google_storage_bucket" "website" {
  name          = "${var.bucket_prefix}-${var.project_id}"
  location      = var.region
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  versioning {
    enabled = true
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "keyless-kingdom"
  }
}

# Make bucket publicly readable for static website hosting
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Grant GitHub Actions service account permission to upload
resource "google_storage_bucket_iam_member" "github_actions_upload" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.github_actions_service_account}"
}

# Reserve a global IP address for load balancer
resource "google_compute_global_address" "website" {
  name = "${var.bucket_prefix}-ip"
}

# Create backend bucket for load balancer
resource "google_compute_backend_bucket" "website" {
  name        = "${var.bucket_prefix}-backend"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

# Create URL map
resource "google_compute_url_map" "website" {
  name            = "${var.bucket_prefix}-url-map"
  default_service = google_compute_backend_bucket.website.id
}

# Create HTTP proxy
resource "google_compute_target_http_proxy" "website" {
  name    = "${var.bucket_prefix}-http-proxy"
  url_map = google_compute_url_map.website.id
}

# Create forwarding rule
resource "google_compute_global_forwarding_rule" "website" {
  name       = "${var.bucket_prefix}-http-rule"
  target     = google_compute_target_http_proxy.website.id
  port_range = "80"
  ip_address = google_compute_global_address.website.address
}

# Optional: HTTPS setup (requires SSL certificate)
# Uncomment if you have a domain and want HTTPS

# resource "google_compute_managed_ssl_certificate" "website" {
#   name = "${var.bucket_prefix}-cert"
#
#   managed {
#     domains = [var.domain_name]
#   }
# }
#
# resource "google_compute_target_https_proxy" "website" {
#   name             = "${var.bucket_prefix}-https-proxy"
#   url_map          = google_compute_url_map.website.id
#   ssl_certificates = [google_compute_managed_ssl_certificate.website.id]
# }
#
# resource "google_compute_global_forwarding_rule" "website_https" {
#   name       = "${var.bucket_prefix}-https-rule"
#   target     = google_compute_target_https_proxy.website.id
#   port_range = "443"
#   ip_address = google_compute_global_address.website.address
# }

# Outputs for GitHub Actions workflow
output "bucket_name" {
  description = "GCS bucket name for deployment"
  value       = google_storage_bucket.website.name
}

output "bucket_url" {
  description = "GCS bucket URL"
  value       = google_storage_bucket.website.url
}

output "website_ip" {
  description = "Global IP address for the website"
  value       = google_compute_global_address.website.address
}

output "website_url" {
  description = "HTTP URL for the website"
  value       = "http://${google_compute_global_address.website.address}"
}

output "deployment_command" {
  description = "Example deployment command for GitHub Actions"
  value = <<-EOT
    # Upload files to GCS
    gcloud storage cp -r ./dist/* gs://${google_storage_bucket.website.name}/

    # Set cache control headers
    gcloud storage objects update gs://${google_storage_bucket.website.name}/** \
      --cache-control="public, max-age=3600"

    # Optionally invalidate CDN cache
    gcloud compute url-maps invalidate-cdn-cache ${google_compute_url_map.website.name} \
      --path "/*"
  EOT
}
