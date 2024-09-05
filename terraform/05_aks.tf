resource "azurerm_kubernetes_cluster" "aks_web" {
  name                = "aks-web"
  location            = "northeurope"
  resource_group_name = var.rg_name
  dns_prefix          = "aks-web1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_web.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_web.kube_config_raw

  sensitive = true
}