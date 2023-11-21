provider "google" { 
  region = var.region
}

module "project" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.project_id}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = var.google_folder
    services = [
    "compute.googleapis.com",
    ]
}

resource "google_project_service" "service_usage" {
  project = "${var.project_id}-${var.timestamp}"
  service = "serviceusage.googleapis.com"
}

output "gce_service_account" {
    value = module.project.service_accounts.default.compute
}
