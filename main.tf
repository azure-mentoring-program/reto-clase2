provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

resource "azurerm_resource_group" "rgdev" {
  name     = local.rg-dev
  location = local.location
}

resource "azurerm_resource_group" "rgprd" {
  name     = local.rg-prd
  location = local.location
}

resource "azurerm_app_service_plan" "plandev" {
  name                = "gestion${local.dev-enviroment}plan"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgdev.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service_plan" "planprd" {
  name                = "gestion${local.prd-enviroment}plan"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgprd.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_dev" {
  name                = "gestion${local.dev-enviroment}web"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgdev.name}"
  app_service_plan_id = "${azurerm_app_service_plan.plandev.id}"
}

resource "azurerm_app_service" "web_prd" {
  name                = "gestion${local.prd-enviroment}web"
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgprd.name}"
  app_service_plan_id = "${azurerm_app_service_plan.planprd.id}"
}

resource "azurerm_virtual_network" "dev" {
  name                = "devvnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgdev.name}"
}

resource "azurerm_subnet" "dev" {
  name                 = "AzureFirewallDevSubnet"
  resource_group_name  = "${azurerm_resource_group.rgdev.name}"
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "prd" {
  name                = "prdvnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = "${azurerm_resource_group.rgprd.name}"
}

resource "azurerm_subnet" "prd" {
  name                 = "AzureFirewallPrdSubnet"
  resource_group_name  = "${azurerm_resource_group.rgprd.name}"
  virtual_network_name = azurerm_virtual_network.prd.name
  address_prefixes     = ["10.0.1.0/24"]
}