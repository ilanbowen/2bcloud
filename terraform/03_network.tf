
resource "azurerm_network_security_group" "cicd_sg" {
  name                = "cicd-sg"
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_virtual_network" "cicd_vnet" {
  name                = "cicd-vnet"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cicd_subnet" {
  name                 = "cicd-subnet"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.cicd_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "cicd_vm_ip" {
  name                = "cicd-vm-ip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "app_ip" {
  name                = "app_ip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  domain_name_label   = "myapp1"
}

resource "azurerm_network_interface" "cicd_vm_nic" {
 name                = "cicd-vm-nic"
 location            = var.rg_location
 resource_group_name = var.rg_name

 ip_configuration {
   name                          = "external"
   subnet_id                     = azurerm_subnet.cicd_subnet.id
   private_ip_address_allocation = "Dynamic"
   public_ip_address_id = azurerm_public_ip.cicd_vm_ip.id
 }
}

