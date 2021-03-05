# provider "azurerm" {
#   # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
#   features {}
# }

# resource "azurerm_resource_group" "RG frontend" {
#   name     = "frontend-rg"
#   location = locals.location
# }

# resource "azurerm_resource_group" "RG backend" {
#   name     = "backend-rg"
#   location = locals.location
# }

# resource "azurerm_storage_account" "SA cdn" {
#   name                     = "cdn-sa"
#   resource_group_name      = azurerm_resource_group.example.name
#   location                 = azurerm_resource_group.example.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = "staging"
#   }
# }

provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

resource "azurerm_resource_group" "GP Dev" {
  name     = locals.rg_dev
  location = locals.location
}

resource "azurerm_resource_group" "GP Prd" {
  name     = locals.rg_prd
  location = locals.location
}

resource "azurerm_app_service_plan" "plan dev" {
  name                = "gestion-${gestion.dev_enviroment}-plan"
  location            = locals.location
  resource_group_name = locals.rg_dev

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service_plan" "plan prd" {
  name                = "gestion-${gestion.prd_enviroment}-plan"
  location            = locals.location
  resource_group_name = locals.rg_prd

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web dev" {
  name                = "gestion-${gestion.dev_enviroment}-web"
  location            = locals.location
  resource_group_name = locals.rg_dev
  app_service_plan_id = "gestion-${gestion.dev_enviroment}-plan"
}

resource "azurerm_app_service" "web prd" {
  name                = "gestion-${gestion.prd_enviroment}-web"
  location            = locals.location
  resource_group_name = locals.rg_prd
  app_service_plan_id = "gestion-${gestion.prd_enviroment}-plan"
}