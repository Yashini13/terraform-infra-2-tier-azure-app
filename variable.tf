variable "subscription_id" {
  type = string
  default = "a85b2ebf-e5bf-4744-b1df-0d89f533c5ba"
}

variable "location" {
  type    = string
  default = "centralus"
}

variable "resource_group_name" {
  type    = string
  default = "rg-2tier-demo"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "vmss_instance_count" {
  type    = number
  default = 1
}

variable "db_admin_username" {
  type      = string
  default   = "sqladmin"
  sensitive = true
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}

# variable "ssl_certificate_password" {
#   type      = string
#   default = "YashiniP@13"
#   sensitive = true
# }

variable "ssl_certificate_password" {
  description = "Password for the SSL certificate"
  type        = string
  sensitive   = true
}