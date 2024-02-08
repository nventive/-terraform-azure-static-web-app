locals {
  custom_domain_enabled               = var.custom_sub_domain_name != null
  custom_sub_domain_name              = var.custom_sub_domain_name != null ? var.custom_sub_domain_name : module.this.id
  parent_dns_zone_name                = join("", data.azurerm_dns_zone.parent.*.name)
  parent_dns_zone_resource_group_name = join("", data.azurerm_dns_zone.parent.*.resource_group_name)
  dns_cname_record_name               = join("", data.azurerm_dns_cname_record.default.*.name)
  storage_account_name                = var.storage_account_name != null ? var.storage_account_name : module.azurerm_storage_account_label.id
}

module "azurerm_storage_account_label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  context   = module.this.context
  delimiter = ""
}

resource "azurerm_storage_account" "default" {
  name                      = local.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_kind              = "StorageV2"
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
  enable_https_traffic_only = true
  tags                      = module.this.tags

  static_website {
    index_document     = var.index_document
    error_404_document = var.error_404_document
  }
}

resource "azurerm_cdn_profile" "default" {
  name                = module.this.id
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.cdn_profile_sku
  tags                = module.this.tags
}

resource "azurerm_cdn_endpoint" "default" {
  name                          = module.this.id
  profile_name                  = azurerm_cdn_profile.default.name
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  origin_host_header            = azurerm_storage_account.default.primary_web_host
  querystring_caching_behaviour = "IgnoreQueryString"
  tags                          = module.this.tags

  origin {
    name      = "websiteorginaccount"
    host_name = azurerm_storage_account.default.primary_web_host
  }

  dynamic "delivery_rule" {
    for_each = var.url_rewrites
    content {
      name  = delivery_rule.value["name"]
      order = delivery_rule.key + 1

      request_uri_condition {
        match_values = [delivery_rule.value["request_url"]]
        operator     = "Contains"
      }

      url_rewrite_action {
        source_pattern          = delivery_rule.value["source_pattern"]
        destination             = delivery_rule.value["destination"]
        preserve_unmatched_path = true
      }
    }
  }
}

data "azurerm_dns_zone" "parent" {
  count = local.custom_domain_enabled ? 1 : 0

  name                = var.parent_dns_zone_name
  resource_group_name = var.parent_dns_zone_resource_group_name
}

resource "azurerm_dns_cname_record" "verify_default" {
  count = local.custom_domain_enabled ? 1 : 0

  name                = "cdnverify.${local.custom_sub_domain_name}"
  zone_name           = local.parent_dns_zone_name
  resource_group_name = local.parent_dns_zone_resource_group_name
  ttl                 = 300
  record              = azurerm_cdn_endpoint.default.fqdn
  tags                = module.this.tags
}

resource "azurerm_dns_cname_record" "default" {
  count = local.custom_domain_enabled ? 1 : 0

  name                = local.custom_sub_domain_name
  zone_name           = local.parent_dns_zone_name
  resource_group_name = local.parent_dns_zone_resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.default.id
  tags                = module.this.tags

  depends_on = [azurerm_dns_cname_record.verify_default]
}

data "azurerm_dns_cname_record" "default" {
  count = local.custom_domain_enabled ? 1 : 0

  name                = join("", azurerm_dns_cname_record.default.*.name)
  zone_name           = local.parent_dns_zone_name
  resource_group_name = local.parent_dns_zone_resource_group_name
}

module "custom_domain_label" {
  count = local.custom_domain_enabled ? 1 : 0

  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  attributes = [local.dns_cname_record_name]
}

resource "azurerm_cdn_endpoint_custom_domain" "default" {
  count = local.custom_domain_enabled ? 1 : 0

  name            = join("", module.custom_domain_label.*.id)
  cdn_endpoint_id = azurerm_cdn_endpoint.default.id
  host_name       = "${local.dns_cname_record_name}.${local.parent_dns_zone_name}"

  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
  }

  depends_on = [azurerm_dns_cname_record.verify_default]
}
