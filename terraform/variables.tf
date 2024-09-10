variable "rg_location" {
  description = "Resource Group Location"
  type = string
}

variable "rg_name" {
  description = "Resource Group Name"
  type = string
}
variable "rg_id" {
  description = "Resource Group ID"
  type = string
}

variable "vm_username" {
  description = "vm_username"
  type = string
}

variable "dns_zone_name" {
  type        = string
  description = "External DNS Zone name"
}
