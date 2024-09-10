resource "azurerm_kubernetes_cluster" "aks_web" {
  name                = "aks-web"
  location            = "northeurope"
  resource_group_name = var.rg_name
  dns_prefix          = "aks-web1"
  oidc_issuer_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
      }
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  name                = "aks-workload-identity"
  location            = "northeurope"
  resource_group_name = var.rg_name
}

resource "azurerm_federated_identity_credential" "workload_identity_credentials" {
  name = "workload-identity-credentials"
  resource_group_name = var.rg_name
  audience = ["api://AzureADTokenExchange"]
  issuer = azurerm_kubernetes_cluster.aks_web.oidc_issuer_url
  parent_id = azurerm_user_assigned_identity.aks_workload_identity.id
  subject = "system:serviceaccount:default:workload-identity"
  depends_on = [
    azurerm_kubernetes_cluster.aks_web,
    azurerm_user_assigned_identity.aks_workload_identity
   ]
  }

output "cluster_host" {
  value = azurerm_kubernetes_cluster.aks_web.kube_config.0.host
  sensitive = true
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_web.kube_config.0.client_certificate
  sensitive = true
}

output "cluster_client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_web.kube_config.0.client_certificate
  sensitive = true
}
output "cluster_client_key" {
  value = azurerm_kubernetes_cluster.aks_web.kube_config.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_web.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "aks_workload_identity_client_id" {
  value = azurerm_user_assigned_identity.aks_workload_identity.client_id
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_web.kube_config_raw

  sensitive = true
}