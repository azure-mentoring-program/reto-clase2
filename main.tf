provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

### ---------- RESOURCE GROUP ---------------

resource "azurerm_resource_group" "rgfrontend" {
  name     = "rg-frontend"
  location = local.location
}

resource "azurerm_resource_group" "rgbackend" {
  name     = "rg-backend"
  location = local.location
}

### ---------- APP PLAN ---------------

resource "azurerm_app_service_plan" "planfrontend" {
  name                = "plan-frontend"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgfrontend.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service_plan" "planbackend" {
  name                = "plan-backend"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgbackend.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

### ---------- APP WEB ---------------

resource "azurerm_app_service" "appfrontend" {
  name                = "web-frontend"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgfrontend.name}"
  app_service_plan_id = "${azurerm_app_service_plan.planfrontend.id}"
}

resource "azurerm_app_service" "appbackend" {
  name                = "eweb-backend"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgbackend.name}"
  app_service_plan_id = "${azurerm_app_service_plan.planbackend.id}"
}


### ---------- CDN ---------------

resource "azurerm_cdn_profile" "cdnprofile" {
  name                = "cdn"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgfrontend.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "example" {
  name                = "example"
  profile_name        = azurerm_cdn_profile.cdnprofile.name
  location            = local.location
  resource_group_name = azurerm_resource_group.rgfrontend.name

  origin {
    name      = "cdng4instagram"
    host_name = "www.cdng4instagram.com"
  }
}