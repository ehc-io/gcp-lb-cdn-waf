provider "google" { 
  region = var.region
}

# resource "google_folder" "default" {
#   display_name = "${var.project_id}-folder-${var.timestamp}"
#   parent       =  var.parent_org
# }

module "project" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.project_id}-${var.timestamp}"
    billing_account     = var.billing_account
    # parent            = google_folder.default.name
    parent              = var.parent_org
    services = [
    "compute.googleapis.com"
    ]
}

output "gce_service_account" {
    value = module.project.service_accounts.default.compute
}
