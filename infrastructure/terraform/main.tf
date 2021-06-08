##################################################################################
# Main Terraform file 
##################################################################################

resource "azurerm_resource_group" "sample" {
  name     = "${var.prefix}-sample-rg"
  location = var.location
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_eventgrid_topic" "sample_topic" {
  name                = "${var.prefix}-azsam-egt"
  location            = var.location
  resource_group_name = azurerm_resource_group.sample.name
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_application_insights" "logging" {
  name                = "${var.prefix}-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.sample.name
  application_type    = "web"
  retention_in_days   = 90
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

resource "azurerm_storage_account" "inbox" {
  name                     = "${var.prefix}inboxsa"
  resource_group_name      = azurerm_resource_group.sample.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  enable_https_traffic_only = true
  tags = {
    sample = "azure-functions-event-grid-terraform"
  }
}

module "functions" {
  source                                   = "./functions"
  prefix                                   = var.prefix
  resource_group_name                      = azurerm_resource_group.sample.name
  location                                 = azurerm_resource_group.sample.location
  application_insights_instrumentation_key = azurerm_application_insights.logging.instrumentation_key
  sample_topic_endpoint                    = azurerm_eventgrid_topic.sample_topic.endpoint
  sample_topic_key                         = azurerm_eventgrid_topic.sample_topic.primary_access_key
}

resource "azurerm_eventgrid_event_subscription" "eventgrid_subscription" {
  name  = "${var.prefix}-handlerfxn-egsub"
  scope = azurerm_storage_account.inbox.id
  labels = [ "azure-functions-event-grid-terraform" ]
  azure_function_endpoint {
    function_id = "${module.functions.function_id}/functions/${var.eventGridFunctionName}"

    # defaults, specified to avoid "no-op" changes when 'apply' is re-ran
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }
}
