resource "google_compute_global_address" "default" {
    name        = "${var.name}-ip"
    project     = module.project.project_id
    address_type = "EXTERNAL"
    ip_version = "IPV4"
    depends_on = [module.project]
}

resource "google_compute_health_check" "http" {
    project = module.project.project_id
    name    = "${var.name}-health-chk"
    check_interval_sec = 5
    healthy_threshold  = 2
    http_health_check {
        port               = 80
        port_specification = "USE_FIXED_PORT"
        proxy_header       = "NONE"
        request_path       = "/"
    }
    timeout_sec         = 5
    unhealthy_threshold = 2
    depends_on = [module.project]
}

resource "google_compute_backend_service" "default" {
    project         = module.project.project_id
    name                            = "${var.name}-backend-service"
    enable_cdn                      = true
    health_checks                   = [google_compute_health_check.http.id]
    
    cdn_policy {
        cache_mode = "USE_ORIGIN_HEADERS"
        negative_caching = false
        signed_url_cache_max_age_sec = 300
        cache_key_policy {
            include_host = true
            include_protocol = true
            include_query_string = true
            # include_http_headers = ["X-My-Header-Field"]
        }
    }

    log_config {
        enable      = true
        sample_rate = 1.0
    }
    
    load_balancing_scheme = "EXTERNAL_MANAGED"
    protocol              = "HTTP"
    port_name             = "http"
    security_policy       = try(google_compute_security_policy.basic-waf-policy.name, null)
    backend {
        group = google_compute_instance_group_manager.default.instance_group
    }
}

resource "google_compute_url_map" "default" {
    project         = module.project.project_id
    name            = "${var.name}-lb"
    default_service = google_compute_backend_service.default.id
    depends_on = [ google_compute_backend_service.default ]
}

resource "google_compute_target_http_proxy" "default" {
    project         = module.project.project_id
    name    = "${var.name}-lb-proxy"
    url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
    project         = module.project.project_id
    name                  = "${var.name}-http-lb-forwarding-rule"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL_MANAGED"
    port_range            = "80-80"
    target                = google_compute_target_http_proxy.default.id
    ip_address            = google_compute_global_address.default.id
    
    depends_on = [ module.vpc.subnets, google_compute_target_http_proxy.default ]

}

output "lb" { 
    value = google_compute_global_address.default
}
