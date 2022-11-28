variable "timestamp" {
    default = "1669382069"
}

variable "project_id" { 
    default = "lb-waf"
}

variable "billing_account" { 
    default = "<billing-account-id>"
}

variable "parent_org" { 
    default = "organizations/<org-id>"
}

variable "vpc_name" { 
    default = "waf-demo"
}

variable "region" {
    default = "us-central1"

}

variable "zone" {
    type = string
    description = "Zone"
    default = "us-central1-c"
}

variable "name" {
    type = string
    description = "The base name of resources"
    default = "waf-demo"
}

variable "machine_type" {
    type = string
    default = "e2-micro"
}

variable "subnet_backend" {
  default = "backend"
}

variable "network_cidr_backend" {
  default = "10.0.10.0/24"

}

variable "remote_ips" {
  default = ["179.98.179.66/32"]
}

variable "health_check_source_ranges" {
  default = ["130.211.0.0/22", "35.191.0.0/16"]
}

variable "network_tags" {
    default = "nginx"
}

