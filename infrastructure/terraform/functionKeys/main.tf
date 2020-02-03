# Gets the host key for the Function App in which the Target Function for an Event Grid Subscription lives
# Does this by committing a "blank" ARM template targeting the function app, then asking ARM for the host keys and outputting as a Terraform variable

variable "function_app_name" {
  type        = string
  description = "The name of the FunctionApp in to which the Functions were deployed"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group the Function App was deployed in to"
}

resource "azurerm_template_deployment" "function_keys" {
  name = "getFunctionAppHostKey"
  parameters = {
    "functionApp" = var.function_app_name
  }
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_body = <<BODY
  {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
          "functionApp": {"type": "string", "defaultValue": ""}
      },
      "variables": {
          "functionAppId": "[resourceId('Microsoft.Web/sites', parameters('functionApp'))]"
      },
      "resources": [
      ],
      "outputs": {
          "functionkey": {
              "type": "string",
              "value": "[listkeys(concat(variables('functionAppId'), '/host/default'), '2018-11-01').systemKeys.eventgrid_extension]"                                                                                
            }
       }
  }
  BODY
}

output "host_key" {
  value = "${lookup(azurerm_template_deployment.function_keys.outputs, "functionkey")}"
}
