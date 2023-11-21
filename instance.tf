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
        # web server config
        curl -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/de926bb5370b171234f4873ed1ab251a/raw/09427e85c8dc3fc5e7a43eac449c2653dc5a4ef3/app.conf
        sed -i 's/listen 8080/listen 80/' /etc/nginx/sites-enabled/default
        curl -o /usr/share/nginx/html/index.html https://gist.githubusercontent.com/ehc-io/5248879e9aabbe4444e2ead09be754c0/raw/f4f15bf317f920a0982b0e29d87d66434cd57212/demo-index.html
        # web server-2 config
        host=$(hostname) ; echo "Webserver: $host" > /usr/share/nginx/html/txt.html
        systemctl restart nginx.service
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