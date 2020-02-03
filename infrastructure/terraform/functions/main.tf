# Windows consumption function app
resource "azurerm_app_service_plan" "fxnapp" {
  name                = format("%s-fxn-plan-%s", var.prefix, var.environment)
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "functionapp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

# # Linux consumption function app
# resource "azurerm_app_service_plan" "fxnapp" {
#   name                = format("%s-fxn-lxplan-%s", var.prefix, var.environment)
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   kind                = "functionapp"
#   reserved            = true
#   sku {
#     tier = "Dynamic"
#     size = "Y1"
#   }
#   tags = {
#     sample = "azure-functions-event-grid-terraform"
#   }
# }

# # Windows Containers consumption function app
# resource "azurerm_app_service_plan" "fxnapp" {
#   name                = format("%s-fxn-wcplan-%s", var.prefix, var.environment)
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   kind                = "functionapp"
#   reserved            = true
#   is_xenon            = true
#   sku {
#     tier = "Dynamic"
#     size = "Y1"
#   }
#   tags = {
#     sample = "azure-functions-event-grid-terraform"
#   }
# }

# Storage account for Azure Function
resource "azurerm_storage_account" "fxnstor" {
  name                     = format("%sfxnssa%s", var.prefix, var.environment)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_function_app" "fxn" {
  name                      = format("%s-fxn-%s", var.prefix, var.environment)
  location                  = var.location
  resource_group_name       = var.resource_group_name
  app_service_plan_id       = azurerm_app_service_plan.fxnapp.id
  storage_connection_string = azurerm_storage_account.fxnstor.primary_connection_string
  version                   = "~3"
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = var.application_insights_instrumentation_key
    SAMPLE_TOPIC_END_POINT       = var.sample_topic_endpoint
    SAMPLE_TOPIC_KEY             = var.sample_topic_key
    # these are added as placeholder so updates on Azure side (from deploys) are ignored (by below lifecycle attribute)
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  # We ignore these because they're set/changed by Function deployment
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}
