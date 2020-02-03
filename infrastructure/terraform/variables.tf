variable "prefix" {
  type        = string
  description = "Prefix given to all resources. Try to make this unique to you"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "West US"
}

variable "eventGridFunctionName" {
  type        = string
  description = "The name of the Function which handles Event Grid messages"
  default     = "StorageHandler"
}
