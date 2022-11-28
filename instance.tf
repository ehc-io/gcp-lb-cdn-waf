data "google_compute_image" "default" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_disk" "default" {
  project   = module.project.project_id
  name  = "ubuntu-image-disk"
  image = data.google_compute_image.default.self_link
  size  = 10
  type  = "pd-balanced"
  zone  = var.zone
  depends_on = [
    module.vpc
  ]
  }

resource "google_compute_instance_template" "default" {
    project     = module.project.project_id
    name        = "${var.name}-nginx-template"
    description = "This template is used to create nginx server instances."
    instance_description = "NGINX instance"
    machine_type         = var.machine_type
    can_ip_forward       = false

    metadata = {
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        sudo apt-get install -y nginx
        sudo curl -s -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/9f8042539db435a9e6d27e3cc7dbfb00/raw/2f38727695f22a5954278f49f645802984d73b35/nginx-cache-config
        sudo curl -s -o /var/www/html/video.mp4 https://static.canva.com/anon_home/benefits-start-en-1200x780-compressed.mp4
        sudo curl -o /var/www/html/cloud-logo.svg https://www.gstatic.com/devrel-devsite/prod/v0427f8a5788f798e3d6bd6e8789f9c1353ea9d7c80868d11a32bd9516fe63280/cloud/images/cloud-logo.svg
        sudo systemctl restart nginx.service
        EOT
    }

    tags = [ var.network_tags ]

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

  // Create a new boot disk from an image
    disk {
        source_image      = "ubuntu-os-cloud/ubuntu-2004-lts"
        auto_delete       = true
        boot              = true
    }
    
    network_interface {
        network = module.vpc.network_name
        subnetwork = module.vpc.subnets_ids[0]
    }    

  service_account {
    email  = module.project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "default" {
    project            = module.project.project_id
    name               = "${var.name}-mig"
    zone               = var.zone
    target_size        = 1
    base_instance_name = "${var.name}-mig"

    version {
        instance_template = google_compute_instance_template.default.id
        name = "primary"
    }
    named_port {
        name = "http"
        port = "80"
    }
} 