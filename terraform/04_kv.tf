
resource "azurerm_key_vault" "kv_web2b1" {
  name                        = "kv-web2b1"
  location                    = var.rg_location
  resource_group_name         = var.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
  soft_delete_retention_days  = 7
  enable_rbac_authorization = false
  #purge_protection_enabled = true

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
  }
}



resource "azurerm_private_dns_zone" "akv_01" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name         = var.rg_name
}

resource "azurerm_private_endpoint" "akv_01" {
  name                          = "pvep-akv"
  resource_group_name           = var.rg_name
  location                      = var.rg_location
  subnet_id                     = azurerm_subnet.cicd_subnet.id
  custom_network_interface_name = "pvep-akv-nic"
 
  private_service_connection {
    name                           = "prod-akv01-private-endpoint"
    private_connection_resource_id = azurerm_key_vault.kv_web2b1.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
 
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.akv_01.name
    private_dns_zone_ids = [azurerm_private_dns_zone.akv_01.id]
  }
 
  depends_on = [azurerm_subnet.cicd_subnet, azurerm_private_dns_zone.akv_01]
}

resource "azurerm_private_dns_zone_virtual_network_link" "akv_01" {
  name                  = "prod-akv"
  private_dns_zone_name = azurerm_private_dns_zone.akv_01.name
  virtual_network_id    = azurerm_virtual_network.cicd_vnet.id
  resource_group_name   = var.rg_name
}


resource "azurerm_key_vault_secret" "vm_pwd" {
  name         = "vm-password"
  value        = random_password.vmgenpassword.result
  key_vault_id = azurerm_key_vault.kv_web2b1.id
  depends_on = [ 
    azurerm_key_vault.kv_web2b1
   ]
}

resource "azurerm_key_vault_secret" "my-secret" {
  name         = "my-secret"
  value        = "super-secret"
  key_vault_id = azurerm_key_vault.kv_web2b1.id
  depends_on = [ 
    azurerm_key_vault_access_policy.terraform_policy
   ]
}

resource "random_password" "vmgenpassword" {
    length = 12
    special = true
    numeric = true
    override_special = "#$*@!"
    min_lower = 2
    min_upper = 3
    min_numeric = 2
    min_special = 2    
}

output "keyvault_uri" {
  value = azurerm_key_vault.kv_web2b1.vault_uri
}


/* resource "azurerm_key_vault_access_policy" "aks_workload_identity_policy" {
  key_vault_id = azurerm_key_vault.kv_web2b1.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  storage_permissions = []
  
  key_permissions = [
    "Create",
    "Get",
    ]

  secret_permissions = [
    "Set",
    "Get",
    "List",
    "Delete",
    "Purge"
  ]

  depends_on = [ azurerm_key_vault.kv_web2b1 ]
} */

resource "azurerm_key_vault_access_policy" "terraform_policy" {
  key_vault_id = azurerm_key_vault.kv_web2b1.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  storage_permissions = []
  
  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
  depends_on = [ azurerm_key_vault.kv_web2b1 ]
}