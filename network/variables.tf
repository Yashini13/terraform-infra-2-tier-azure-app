variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-2tier-demo"
}

variable "appgw_subnet_name" {
  description = "AppGW subnet name"
  type        = string
  default     = "snet-appgw"
}

variable "vmss_subnet_name" {
  description = "VMSS subnet name"
  type        = string
  default     = "snet-vmss"
}

variable "db_subnet_name" {
  description = "Database subnet name"
  type        = string
  default     = "snet-db"
}

variable "sql_server_id" {
  description = "SQL Server resource ID for private endpoint"
  type        = string
}