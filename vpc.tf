#
module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 5.2"
  project_id   = module.project.project_id
  network_name = "${var.name}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  subnets = [
    {
      subnet_name   = var.subnet_backend
      subnet_ip     = var.network_cidr_backend
      subnet_region = var.region
    }
  ]
  depends_on = [module.project.name]
}

resource "google_compute_router" "router" {
  project = module.project.project_id
  name    = "${var.name}-router"
  region  = var.region
  network = module.vpc.network_id
  bgp {
    asn = 64514
  }
  depends_on = [module.vpc]
}

resource "google_compute_router_nat" "nat" {
    project = module.project.project_id
    name                               = "${var.name}-router-nat"
    router                             = google_compute_router.router.name
    region                             = var.region
    nat_ip_allocate_option             = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

    log_config {
    enable = true
    filter = "ERRORS_ONLY"
    }
}

resource "google_compute_firewall" "allow-http" {
    project = module.project.project_id
    name = "allow-http"
    network = module.vpc.network_name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = var.health_check_source_ranges
    target_tags =  [ var.network_tags ]
    allow {
    protocol = "tcp"
    ports    = ["80"]
    }
}
resource "google_compute_firewall" "allow-ssh" {
    project = module.project.project_id
    name = "allow-ssh"
    network = module.vpc.network_name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = ["0.0.0.0/0"]
    target_tags =  [ var.network_tags ]
    allow {
    protocol = "tcp"
    ports    = ["22"]
    }
}

