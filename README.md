---
page_type: sample
languages:
- csharp
- yaml
products:
- dotnet
- dotnet-core
- azure-functions
- azure-event-grid
- azure-storage
- azure-blob-storage
- azure-devops
---

# Subscribing an Azure Function to Event Grid Events via Terraform

This sample will show you how to create Terraform scripts that create an Azure Function and Subscribe it to Event Grid Storage events.
This is especially interesting as, for Event Grid Subscriptions, the target endpoint must answer EG's "[Subscription Validation Event](https://docs.microsoft.com/en-us/azure/event-grid/security-authentication#validation-details)" which it cannot do until it is deployed. So this method - a "Terraform Sandwich" - shows how to do just that.

## Running the sample
1. Open the repo in its VS Code Dev Container (this ensures you have all the right versions of the necessary tooling)
1. run `az login` and `az account set --subscription <target subscription id>` to connect to your Azure Subscription
1. `cd terraform`
1. run `terraform apply -var 'prefix=<some unique prefix here>' -target module.storage -target module.functions`
1. `cd ../src/FunctionApp`
1. run `func azure functionapp publish <the name of the functionapp outputted by terraform apply> --csharp`
1. run `terraform apply -var 'prefix=<same prefix as before>'`

## What it does
- This command tells terraform to run everything **except** the event grid subscription piece
- Deploys the function app out to Azure so it's ready to answer the subscription wire-up that Terraform will do in step
- Issues the necessary changes to Azure to add the event grid subscription

## Automating it
This process can be automated with Azure Devops! See the yaml files under [azure-piplines](./azure-pipelines).