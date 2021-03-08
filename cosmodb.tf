provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

#Compliance Landing Zone For company, Production 
resource "azurerm_resource_group" "rg" {
  name     = "demo-resource-group1"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "stactestxx01"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#cosmodb
resource  "azurerm_cosmosdb_account" "example" {
  name                = "tfex-cosmosdb-account"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "East US"
  offer_type          = "Standard"
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }
  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "example" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  account_name        = "${azurerm_cosmosdb_account.example.name}"
}

resource "azurerm_cosmosdb_mongo_collection" "example" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  account_name        = "${azurerm_cosmosdb_account.example.name}"
  database_name       = "${azurerm_cosmosdb_mongo_database.example.name}"
  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400
}

