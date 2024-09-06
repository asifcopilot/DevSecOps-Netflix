
# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "${var.prefix}-aks"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "${var.prefix}-vote-aks"
  


#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#     os_sku     = "Ubuntu"
#     os_disk_size_gb = 30
    
#   }

#   role_based_access_control_enabled = true
#   node_resource_group = "${var.prefix}-aks-node-rg"

#   key_vault_secrets_provider {
#     secret_rotation_enabled = true
#     secret_rotation_interval = "1m"
#     }

#     identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     environment = var.environment
#   }
# }


# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw
#   sensitive = true
# }


