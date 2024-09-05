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

variable "vm_password" {
  description = "vm_password"
  type = string
}

variable "private_key_path" {
  type        = string
  description = "Path to SSH private key"
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

