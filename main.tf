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
  resource_group_name = azurerm_resource_group.rgfrontend.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service_plan" "planbackend" {
  name                = "plan-backend"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgbackend.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

### ---------- APP WEB ---------------

resource "azurerm_app_service" "appfrontend" {
  name                = "web-frontend"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgfrontend.name
  app_service_plan_id = azurerm_app_service_plan.planfrontend.id
}

resource "azurerm_app_service" "appbackend" {
  name                = "web-backend"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgbackend.name
  app_service_plan_id = azurerm_app_service_plan.planbackend.id
}


### ---------- CDN ---------------

resource "azurerm_cdn_profile" "cdnprofile" {
  name                = "cdn-profile"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgfrontend.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "cdnendpoint" {
  name                = "cdn-endpoint"
  profile_name        = azurerm_cdn_profile.cdnprofile.name
  location            = local.location
  resource_group_name = azurerm_resource_group.rgfrontend.name

  origin {
    name      = "cdng4instagram"
    host_name = "www.cdng4instagram.com"
  }
}

### ---------- SERVICEBUS ---------------

resource "azurerm_servicebus_namespace" "servicebus" {
  name                = "servicebus-namespace"
  location            = local.location
  resource_group_name = azurerm_resource_group.rgbackend.name
  sku                 = "Standard"

  tags = {
    # source = "terraform"
  }
}

resource "azurerm_servicebus_queue" "servicebusqueue" {
  name                = "servicebus-queue"
  resource_group_name = azurerm_resource_group.rgbackend.name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name

  enable_partitioning = true
}

### ---------- COSMOSDB ---------------

resource "azurerm_storage_account" "storageaccount" {
  name                     = "storageaccount"
  resource_group_name      = azurerm_resource_group.rgbackend.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource  "azurerm_cosmosdb_account" "cosmosdbaccount" {
  name                = "cosmosdb"
  resource_group_name = azurerm_resource_group.rgbackend.name
  location            = local.location
  offer_type          = "Standard"
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }
  geo_location {
    location          = local.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "mongodb"
  resource_group_name = azurerm_resource_group.rgbackend.name
  account_name        = azurerm_cosmosdb_account.cosmosdbaccount.name
}

resource "azurerm_cosmosdb_mongo_collection" "collection" {
  name                = "collection"
  resource_group_name = azurerm_resource_group.rgbackend.name
  account_name        = azurerm_cosmosdb_account.cosmosdbaccount.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400
}