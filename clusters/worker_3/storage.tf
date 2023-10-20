locals {
  storage_containers = [
    "loki"
  ]
}

resource "azurerm_storage_account" "storage" {
  for_each = toset(local.storage_containers)

  name                            = "ghworker3${each.key}"
  resource_group_name             = data.azurerm_resource_group.default.name
  location                        = data.azurerm_resource_group.default.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "storage" {
  for_each = toset(local.storage_containers)

  name                 = each.key
  storage_account_name = resource.azurerm_storage_account.storage[each.key].name
}
