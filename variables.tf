variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the App Service to."
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group to deploy the App Service to."
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
}

variable "storage_account_tier" {
  type        = string
  default     = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
}

variable "custom_sub_domain_name" {
  type        = string
  description = "Subdomain to use, i.e.: use myapp as in myapp.contoso.com"
  default     = null
}

variable "storage_account_replication_type" {
  type        = string
  default     = "GRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
}

variable "cdn_profile_sku" {
  type    = string
  default = "Standard_Microsoft"
}

variable "parent_dns_zone_name" {
  type    = string
  default = null
}

variable "parent_dns_zone_resource_group_name" {
  type    = string
  default = null
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_404_document" {
  type    = string
  default = "404.html"
}

variable "url_rewrites" {
  type = list(object({
    name           = string
    request_url    = string
    source_pattern = string
    destination    = string
  }))
  description = "List of URL rewrites."
  default     = []
}
