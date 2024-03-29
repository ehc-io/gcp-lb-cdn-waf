resource "google_compute_security_policy" "owasp-policy" {
    provider    = google-beta
    project     = module.project.project_id
    name        = "owasp-policy"
    description = "Default rule, Top 10 OWASP, Throttling & Log4J custom rules"
    advanced_options_config{
        log_level = "VERBOSE"
        # json_parsing = "DISABLED"
    }
    # --------------------------------- 
    # Default rules
    # --------------------------------- 
        dynamic "rule" {
            for_each = var.allow_rules
            content {
                action      = rule.value.action
                priority    = rule.value.priority
                description = rule.value.description
                preview     = rule.value.preview
                match {
                    versioned_expr = rule.value.versioned_expr
                    config {
                        src_ip_ranges = rule.value.src_ip_ranges
                    }
                }
            }  
    }
        
    # --------------------------------- 
    # Throttling traffic rules
    # --------------------------------- 
        dynamic "rule" {
            for_each = var.throttle_rules
            content {
                action      = rule.value.action
                priority    = rule.value.priority
                description = rule.value.description
                preview     = rule.value.preview
                match {
                    versioned_expr = rule.value.versioned_expr
                    config {
                        src_ip_ranges = rule.value.src_ip_ranges
                    }
                }
                rate_limit_options {
                    conform_action  = rule.value.conform_action
                    exceed_action   = rule.value.exceed_action
                    enforce_on_key  = rule.value.enforce_on_key
                    rate_limit_threshold {
                        count           = rule.value.rate_limit_threshold_count
                        interval_sec    = rule.value.rate_limit_threshold_interval_sec
                    }
                } 
            }
    }

    # --------------------------------- 
    # Country limitation
    # --------------------------------- 
        dynamic "rule" {
            for_each = var.countries_rules
            content {
                action      = rule.value.action
                priority    = rule.value.priority
                description = rule.value.description
                preview     = rule.value.preview
                match {
                    expr {
                        expression = rule.value.expression
                    }
                }
            }
    }

    # --------------------------------- 
    # OWASP top 10 rules
    # --------------------------------- 
        dynamic "rule" {
            for_each = var.owasp_rules
            content {
                action      = rule.value.action
                priority    = rule.value.priority
                description = rule.value.description
                preview     = rule.value.preview
                match {
                    expr {
                        expression = rule.value.expression
                    }
                }
            }
    }

    # --------------------------------- 
    # Custom Log4j rule
    # --------------------------------- 
        dynamic "rule" {
            for_each = var.apache_log4j_rule
            content {
                action      = rule.value.action
                priority    = rule.value.priority
                description = rule.value.description
                preview     = rule.value.preview
                match {
                    expr {
                        expression = rule.value.expression
                    }
                }
            }
    }
}

###########
# WAF Rules
# --------------------------------- 
# Bypass Allow
# --------------------------------- 
variable "allow_rules" {
    default = {
        def_rule = {
            action          = "allow"
            priority        = "2147483647"
            versioned_expr = "SRC_IPS_V1"
            src_ip_ranges   = ["*"]
            # src_ip_ranges   = ["186.204.109.200"]
            description     = "Default rule"
            preview         = false
        }
    }
    type = map(object({
        action              = string
        priority            = string
        versioned_expr      = string
        src_ip_ranges       = list(string)
        description         = string
        preview             = bool
        })
    )
} 

# --------------------------------- 
# Throttling traffic rules
# --------------------------------- 
variable "throttle_rules" {
    default = {
        def_rule = {
            action                              = "throttle"
            priority                            = "4000"
            versioned_expr                      = "SRC_IPS_V1"
            src_ip_ranges                       = ["*"]
            description                         = "Throttling traffic rule"
            conform_action                      = "allow"
            exceed_action                       = "deny(429)"
            enforce_on_key                      = "ALL"                           #https://cloud.google.com/armor/docs/rate-limiting-overview#identifying_clients_for_rate_limiting
            rate_limit_threshold_count          = "100"
            rate_limit_threshold_interval_sec   = "60"
            preview                             = false
        }
    }
    type = map(object({
        action                              = string
        priority                            = string
        versioned_expr                      = string
        src_ip_ranges                       = list(string)
        description                         = string
        conform_action                      = string
        exceed_action                       = string
        enforce_on_key                      = string
        rate_limit_threshold_count          = number
        rate_limit_threshold_interval_sec   = number
        preview                             = bool
        })
    )
} 

# --------------------------------- 
# Countries limitation rules
# --------------------------------- 
variable "countries_rules" {
    default = {
        def_rule = {
            action                              = "deny(403)"
            priority                            = "3000"
            expression                          = "'[CN, RU]'.contains(origin.region_code)"
            description                         = "Deny if region code is listed"
            preview                             = false
        }
    }
    type = map(object({
        action                              = string
        priority                            = string
        expression                          = string
        description                         = string
        preview                             = bool
        })
    )
} 
# --------------------------------- 
# OWASP top 10 rules
# --------------------------------- 
variable "owasp_rules" {
    default = {
        #https://cloud.google.com/armor/docs/rule-tuning#sql_injection_sqli
        rule_sqli = {
            action      = "deny(403)"
            priority    = "1000"
            description = "SQL injection"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('sqli-stable',['owasp-crs-v030001-id942110-sqli','owasp-crs-v030001-id942120-sqli','owasp-crs-v030001-id942150-sqli','owasp-crs-v030001-id942180-sqli','owasp-crs-v030001-id942200-sqli','owasp-crs-v030001-id942210-sqli','owasp-crs-v030001-id942260-sqli','owasp-crs-v030001-id942300-sqli','owasp-crs-v030001-id942310-sqli','owasp-crs-v030001-id942330-sqli','owasp-crs-v030001-id942340-sqli','owasp-crs-v030001-id942380-sqli','owasp-crs-v030001-id942390-sqli','owasp-crs-v030001-id942400-sqli','owasp-crs-v030001-id942410-sqli','owasp-crs-v030001-id942430-sqli','owasp-crs-v030001-id942440-sqli','owasp-crs-v030001-id942450-sqli','owasp-crs-v030001-id942251-sqli','owasp-crs-v030001-id942420-sqli','owasp-crs-v030001-id942431-sqli','owasp-crs-v030001-id942460-sqli','owasp-crs-v030001-id942421-sqli','owasp-crs-v030001-id942432-sqli'])"
            
            ### Detect Level 1 & 2
            #expression  = "evaluatePreconfiguredExpr('sqli-stable',['owasp-crs-v030001-id942251-sqli','owasp-crs-v030001-id942420-sqli','owasp-crs-v030001-id942431-sqli','owasp-crs-v030001-id942460-sqli','owasp-crs-v030001-id942421-sqli','owasp-crs-v030001-id942432-sqli'])"
            
            ### Detect Level 1,2 & 3
            #expression  = "evaluatePreconfiguredExpr('sqli-stable',['owasp-crs-v030001-id942421-sqli','owasp-crs-v030001-id942432-sqli'])"
            
            ### Detect Level 1,2,3 & 4
            expression  = "evaluatePreconfiguredExpr('sqli-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#cross-site_scripting_xss
        rule_xss = {
            action      = "deny(403)"
            priority    = "1001"
            description = "Cross-site scripting"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('xss-stable',['owasp-crs-v030001-id941150-xss','owasp-crs-v030001-id941320-xss','owasp-crs-v030001-id941330-xss','owasp-crs-v030001-id941340-xss'])"
            
            ### Detect Level 1 & 2
            expression  = "evaluatePreconfiguredExpr('xss-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#local_file_inclusion_lfi
        rule_lfi = {
            action      = "deny(403)"
            priority    = "1002"
            description = "Local file inclusion"
            preview     = false
            
            ### Detect Level 1
            expression  = "evaluatePreconfiguredExpr('lfi-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#remote_code_execution_rce
        rule_rce = {
            action      = "deny(403)"
            priority    = "1003"
            description = "Remote code execution"
            preview     = false
           
            ### Detect Level 1
            expression  = "evaluatePreconfiguredExpr('rce-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#remote_file_inclusion_rfi
        rule_rfi = {
            action      = "deny(403)"
            priority    = "1004"
            description = "Remote file inclusion"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('rfi-stable', ['owasp-crs-v030001-id931130-rfi'])"

            ### Detect Level 1 & 2
            expression  = "evaluatePreconfiguredExpr('rfi-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#method_enforcement
        rule_methodenforcement = {
            action      = "deny(403)"
            priority    = "1005"
            description = "Method enforcement"
            preview     = false
            
            ### Detect Level 1
            expression  = "evaluatePreconfiguredExpr('methodenforcement-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#scanner_detection
        rule_scandetection = { 
            action      = "deny(403)"
            priority    = "1006"
            description = "Scanner detection"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('scannerdetection-stable',['owasp-crs-v030001-id913101-scannerdetection','owasp-crs-v030001-id913102-scannerdetection'])"

            ### Detect Level 1 & 2
            expression  = "evaluatePreconfiguredExpr('scannerdetection-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#protocol_attack
        rule_protocolattack = { 
            action      = "deny(403)"
            priority    = "1007"
            description = "Protocol Attack"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('protocolattack-stable',['owasp-crs-v030001-id921151-protocolattack','owasp-crs-v030001-id921170-protocolattack'])"                  
            
            ### Detect Level 1 & 2
            #expression  = "evaluatePreconfiguredExpr('protocolattack-stable',['owasp-crs-v030001-id921170-protocolattack'])"
            
            ### Detect Level 1,2 & 3
            expression  = "evaluatePreconfiguredExpr('protocolattack-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#php
        rule_php = { 
            action      = "deny(403)"
            priority    = "1008"
            description = "PHP"
            preview     = false
            
            ### Detect Level 1
            #expression  = "evaluatePreconfiguredExpr('php-stable',['owasp-crs-v030001-id933151-php','owasp-crs-v030001-id933131-php','owasp-crs-v030001-id933161-php','owasp-crs-v030001-id933111-php'])"
            
            ### Detect Level 1 & 2
            #expression  = "evaluatePreconfiguredExpr('php-stable',['owasp-crs-v030001-id933131-php','owasp-crs-v030001-id933161-php','owasp-crs-v030001-id933111-php'])"
            
            ### Detect Level 1,2 & 3
            expression  = "evaluatePreconfiguredExpr('php-stable')"
        }
        #https://cloud.google.com/armor/docs/rule-tuning#session_fixation
        rule_sessionfixation = { 
            action      = "deny(403)"
            priority    = "1009"
            description = "Session Fixation"
            preview     = false
            
            ### Detect Level 1
            expression  = "evaluatePreconfiguredExpr('sessionfixation-stable')"
        }
    }
    type = map(object({
        action      = string
        priority    = string
        description = string
        preview     = bool
        expression  = string
        })
    )
}

# --------------------------------- 
# Custom Log4j rules
# --------------------------------- 
variable "apache_log4j_rule" {
    default = {
        # https://cloud.google.com/armor/docs/rule-tuning#cves_and_other_vulnerabilities
        rule_apache_log4j = {
            action          = "deny(403)"
            priority        = "2000"
            description     = "Apache Log4j CVE-2021-44228"
            preview         = false

            ### Detect Level 1 Basic rule
            #expression      = "evaluatePreconfiguredExpr('cve-canary',['owasp-crs-v030001-id144228-cve','owasp-crs-v030001-id244228-cve','owasp-crs-v030001-id344228-cve'])"
            
            ### Detect Level 1 only
            #expression      = "evaluatePreconfiguredExpr('cve-canary',['owasp-crs-v030001-id244228-cve','owasp-crs-v030001-id344228-cve'])"
            
            ### Detect Level 1 & 3, decrease sensitivity
            #expression      = "evaluatePreconfiguredExpr('cve-canary',['owasp-crs-v030001-id244228-cve'])"

            ### Detect Level 1 & 3 - very sensitive
            expression      = "evaluatePreconfiguredExpr('cve-canary')"
        }
    }
    type = map(object({
        action      = string
        priority    = string
        description = string
        preview     = bool
        expression  = string
        })
    )
}

# output "security_policies" {
#     value = google_compute_security_policy.waf-policy
# }