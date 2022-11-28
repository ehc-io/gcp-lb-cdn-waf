resource "google_compute_security_policy" "basic-waf-policy" {
    name    = "waf-policy"
    project = module.project.project_id
    description = "Basic WAF policy"
    advanced_options_config{
        log_level = "VERBOSE"
        # json_parsing = "DISABLED"
    }
    rule {
        action   = "allow"
        priority = "1000"
        match {
            versioned_expr = "SRC_IPS_V1"
            config {
            src_ip_ranges = var.remote_ips
            }
        }
        description = "Allow Known Origins"
    }

    rule {
        action   = "deny(403)"
        priority = "2147483647"
        match {
            versioned_expr = "SRC_IPS_V1"
            config {
            src_ip_ranges = ["*"]
            }
        }
        description = "Deny Access to Everyone Else"
    }
}
