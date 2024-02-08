output "storage_account_name" {
  value = azurerm_storage_account.default.name
}

output "cdn_endpoint_fqdn" {
  value = azurerm_cdn_endpoint.default.fqdn
}
