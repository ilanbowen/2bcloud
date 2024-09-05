
resource "azurerm_container_registry" "acr_web" {
  name                = "acrweb2b"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr_web.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_virtual_machine.cicd_vm.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr_web.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_linux_virtual_machine.cicd_vm.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_delete" {
  scope                = azurerm_container_registry.acr_web.id
  role_definition_name = "AcrDelete"
  principal_id         = azurerm_linux_virtual_machine.cicd_vm.identity[0].principal_id
}

resource "azurerm_role_assignment" "kubweb_to_acr" {
  scope                = azurerm_container_registry.acr_web.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_web.kubelet_identity[0].object_id
}