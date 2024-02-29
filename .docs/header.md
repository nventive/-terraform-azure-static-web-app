![nventive](https://nventive-public-assets.s3.amazonaws.com/nventive_logo_github.svg?v=2)

# terraform-azurerm-static-web-app

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![Latest Release](https://img.shields.io/github/release/nventive/terraform-azurerm-static-web-app.svg?style=flat-square)](https://github.com/nventive/terraform-azurerm-static-web-app/releases/latest)

Terraform module to provision a static web app with Azure Storage Account and Azure CDN.

---

## Examples

**IMPORTANT:** We do not pin modules to versions in our examples because of the difficulty of keeping the versions in
the documentation in sync with the latest released versions. We highly recommend that in your code you pin the version
to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way
so that they do not catch you by surprise.

```hcl
module "this" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = "nventive"
  name      = "example"
}

resource "azurerm_resource_group" "example" {
  name     = module.this.id
  location = "Canada Central"
}

module "static_web_app" {
  source = "nventive/static-web-app/azurerm"
  # We recommend pinning every module to a specific version
  # version = "x.x.x"

  context = module.this.context

  resource_group_name     = azurerm_resource_group.example.name
  resource_group_location = azurerm_resource_group.example.location
  storage_account_name    = "examplestorage"
}
```
