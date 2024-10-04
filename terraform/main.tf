# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-myPortfolio-${var.resource_name_suffix}"
  location = var.location
}

#Static Web App
resource "azurerm_static_web_app" "static_app" {
  name                = "myPortfolioWebApp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"
  sku_tier            = "Free"
}

#Function App Service Plan (Consumption Plan)
resource "azurerm_service_plan" "function_app_plan" {
  name                = "ASP-rgmyPortfoliovmc-98d7"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Storage Account for Function App
resource "azurerm_storage_account" "function_storage" {
  name                     = "funcstorageacct${var.resource_name_suffix}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Function App
resource "azurerm_linux_function_app" "function_app" {
  name                       = "myPortfolioFunctionApp-${var.resource_name_suffix}"
  location                   = "eastus"
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.function_app_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "AzureCosmosDBConnectionString" = var.cosmosdb_connection_string
  }
}

#Cosmos DB Account
data "azurerm_cosmosdb_account" "cosmosdb" {
  name                = lower("myPortfolioCosmosDb-${var.resource_name_suffix}")
  resource_group_name = azurerm_resource_group.rg.name

}

# Cosmos DB Database
resource "azurerm_cosmosdb_sql_database" "database" {
  name                = "myPortfolioDb-${var.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb.name
}

# Cosmos DB Container
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "visitorLogs-${var.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.database.name
  partition_key_paths = ["/id"]
}
 