output "functionapp_endpoint_base" {
  value = azurerm_function_app.fxn.default_hostname
}

output "function_app_name" {
  value = azurerm_function_app.fxn.name
}