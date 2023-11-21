variable "timestamp" {
    default = "1699895758"
}

variable "project_id" { 
    default = "lb-waf"
}

variable "billing_account" {
    default = "12345-asdfg-asdfg"
}

variable "google_folder" {
    default = "folders/1234567890"
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
    description = "Cloud Armor Demo"
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
  default = ["186.204.109.200/32"]
}

variable "health_check_source_ranges" {
  default = ["130.211.0.0/22", "35.191.0.0/16"]
}

variable "network_tags" {
    default = "nginx"
}

