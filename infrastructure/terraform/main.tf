##################################################################################
# Main Terraform file 
##################################################################################

resource "azurerm_resource_group" "sample" {
  name     = "${var.prefix}-sample-rg-${var.environment}"
  location = var.location
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_eventgrid_topic" "sample_topic" {
  name                = "${var.prefix}-azsam-egt-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.sample.name
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_application_insights" "logging" {
  name                = format("%s-ai-%s", var.prefix, var.environment)
  location            = var.location
  resource_group_name = azurerm_resource_group.sample.name
  application_type    = "web"
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_storage_account" "inbox" {
  name                     = format("%sinboxsa%s", var.prefix, var.environment)
  resource_group_name      = azurerm_resource_group.sample.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

module "functions" {
  source                                   = "./functions"
  prefix                                   = var.prefix
  environment                              = var.environment
  resource_group_name                      = azurerm_resource_group.sample.name
  location                                 = azurerm_resource_group.sample.location
  application_insights_instrumentation_key = azurerm_application_insights.logging.instrumentation_key
  sample_topic_endpoint                    = azurerm_eventgrid_topic.sample_topic.endpoint
  sample_topic_key                         = azurerm_eventgrid_topic.sample_topic.primary_access_key
}

module "functionKeys" {
  source              = "./functionKeys"
  function_app_name   = module.functions.function_app_name
  resource_group_name = azurerm_resource_group.sample.name
}

resource "azurerm_eventgrid_event_subscription" "eventgrid_subscription" {
  name  = "${var.prefix}-handlerfxn-egsub-${var.environment}"
  scope = azurerm_storage_account.inbox.id
  webhook_endpoint {
    url = "https://${module.functions.functionapp_endpoint_base}/runtime/webhooks/eventgrid?functionName=${var.eventGridFunctionName}&code=${module.functionKeys.host_key}"
  }
}
