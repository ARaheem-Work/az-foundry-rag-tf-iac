resource "random_string" "foundry_subdomain_suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  caf_base = lower(join("-", [var.workload_name, var.environment, var.location_short, var.instance]))

  caf_name = {
    rg                                = "rg-${local.caf_base}"
    vnet                              = "vnet-${local.caf_base}"
    subnet_integration                = "snet-int-${local.caf_base}"
    subnet_private_endpoints          = "snet-pep-${local.caf_base}"
    private_dns_vnet_link             = "vnetlnk-appsvc-${local.caf_base}"
    cosmos_private_dns_vnet_link      = "vnetlnk-cosmos-${local.caf_base}"
    ai_account                        = "ais-${local.caf_base}"
    ai_project                        = "aip-${local.caf_base}"
    ai_deployment                     = "aidep-gpt52-${var.environment}"
    frontend_web_app                  = "appfe-${local.caf_base}"
    backend_web_app                   = "appbe-${local.caf_base}"
    backend_private_endpoint          = "pep-appbe-${local.caf_base}"
    storage_private_endpoint          = "pep-st-${local.caf_base}"
    foundry_private_endpoint          = "pep-ais-${local.caf_base}"
    search_private_endpoint           = "pep-srch-${local.caf_base}"
    speech_private_endpoint           = "pep-speech-${local.caf_base}"
    appservice_private_dns_zone_group = "pdzg-appsvc-${local.caf_base}"
    foundry_private_dns_zone_group    = "pdzg-ais-${local.caf_base}"
    search_private_dns_zone_group     = "pdzg-srch-${local.caf_base}"
    speech_private_dns_zone_group     = "pdzg-speech-${local.caf_base}"
    storage_private_dns_zone_group    = "pdzg-stblob-${local.caf_base}"
    cosmos_private_dns_zone_group     = "pdzg-cosmos-${local.caf_base}"
    private_service_connection        = "psc-appbe-${local.caf_base}"
    storaccount                       = substr(replace("st${local.caf_base}", "-", ""), 0, 24)
    cosmos_account                    = "cosmos-${local.caf_base}"
    speech_account                    = "speech-${local.caf_base}"
    search_service                    = "srch-${local.caf_base}"
  }
}

############################################################################################################################################################################
## Azure Resource Group
resource "azurerm_resource_group" "az_rg" {
  name     = local.caf_name.rg
  location = "westus3"
}


############################################################################################################################################################################
# Azure Virtual Network and Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = local.caf_name.vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_subnet" "integrationsubnet" {
  name                 = local.caf_name.subnet_integration
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "endpointsubnet" {
  name                 = local.caf_name.subnet_private_endpoints
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  #private_endpoint_network_policies = Disabled
}


# Azure Private DNS Zones and Links for App Services
resource "azurerm_private_dns_zone" "appservice_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.az_rg.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "app_service_dns_link" {
  name                  = local.caf_name.private_dns_vnet_link
  resource_group_name   = azurerm_resource_group.az_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.appservice_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# DNS Zone for Azure Cognitive Services private endpoint
resource "azurerm_private_dns_zone" "cognitive_dns" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cognitive_dns_link" {
  name                  = "vnetlnk-cog-${local.caf_base}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cognitive_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# DNS Zone for Azure Search private endpoint 
resource "azurerm_private_dns_zone" "search_dns" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "search_dns_link" {
  name                  = "vnetlnk-srch-${local.caf_base}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.search_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# DNS Zone for Storage Account private endpoints 
resource "azurerm_private_dns_zone" "storage_blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_dns_link" {
  name                  = "vnetlnk-stblob-${local.caf_base}"
  resource_group_name   = azurerm_resource_group.az_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}


# DNS Zone for Cosmos DB private endpoint Document API 
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_dns_link_2" {
  name                  = local.caf_name.cosmos_private_dns_vnet_link
  resource_group_name   = azurerm_resource_group.az_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
############################################################################################################################################################################
## Azure OpenAI Foundry Resources
resource "azurerm_cognitive_account" "foundry_account" {
  name                       = local.caf_name.ai_account
  location                   = azurerm_resource_group.az_rg.location
  resource_group_name        = azurerm_resource_group.az_rg.name
  kind                       = "AIServices"
  sku_name                   = "S0"
  project_management_enabled = true
  custom_subdomain_name      = "${local.caf_name.ai_account}-${random_string.foundry_subdomain_suffix.result}"

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_cognitive_account_project" "foundry_project" {
  name                 = local.caf_name.ai_project
  cognitive_account_id = azurerm_cognitive_account.foundry_account.id
  location             = azurerm_resource_group.az_rg.location
  description          = "Example cognitive services project"
  display_name         = "Example Project"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "test"
  }
}


resource "azurerm_cognitive_deployment" "gpt52_ptu" {
  name                 = local.caf_name.ai_deployment
  cognitive_account_id = azurerm_cognitive_account.foundry_account.id

  model {
    format  = "OpenAI"
    name    = "gpt-5.2"
    version = "2025-12-11"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 10

  }
}

resource "azurerm_private_endpoint" "foundry_pe" {
  name                = local.caf_name.foundry_private_endpoint
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = "psc-ais-${local.caf_base}"
    private_connection_resource_id = azurerm_cognitive_account.foundry_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = local.caf_name.foundry_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.cognitive_dns.id]
  }
}

############################################################################################################################################################################
##Azure App Service for Frontend and Backend

resource "azurerm_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  os_type             = "Windows"
  sku_name            = "P1v2"
}


resource "azurerm_windows_web_app" "frontendwebapp" {
  name                = local.caf_name.frontend_web_app
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  site_config {}


}


resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id = azurerm_windows_web_app.frontendwebapp.id
  subnet_id      = azurerm_subnet.integrationsubnet.id
}


resource "azurerm_windows_web_app" "backendwebapp" {
  name                = local.caf_name.backend_web_app
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  site_config {}
}


resource "azurerm_private_endpoint" "privateendpoint" {
  name                = local.caf_name.backend_private_endpoint
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_dns_zone_group {
    name                 = local.caf_name.appservice_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice_dns.id]
  }

  private_service_connection {
    name                           = local.caf_name.private_service_connection
    private_connection_resource_id = azurerm_windows_web_app.backendwebapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}


############################################################################################################################################################################
## Azure Storage Account

resource "azurerm_storage_account" "example" {
  name                     = local.caf_name.storaccount
  resource_group_name      = azurerm_resource_group.az_rg.name
  location                 = azurerm_resource_group.az_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access for enhanced security
  public_network_access_enabled = false
}


resource "azurerm_private_endpoint" "example" {
  name                = local.caf_name.storage_private_endpoint
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = local.caf_name.private_service_connection
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"] # Use "blob", "file", "table", or "queue"
    is_manual_connection           = false
  }

  # Link to a Private DNS Zone for proper resolution
  private_dns_zone_group {
    name                 = local.caf_name.storage_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob_dns.id]
  }
}

############################################################################################################################################################################
# Azure Cosmos DB
resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                          = local.caf_name.cosmos_account
  location                      = azurerm_resource_group.az_rg.location
  resource_group_name           = azurerm_resource_group.az_rg.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = false # Blocks all public internet entry points

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.az_rg.location
    failover_priority = 0
  }
}



resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "pe-cosmos-account"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = "psc-cosmos"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos_account.id
    subresource_names              = ["Sql"] # Change this value if using MongoDB, Cassandra, etc.
    is_manual_connection           = false
  }

  # Automatically registers the endpoint IP address inside your Private DNS Zone
  private_dns_zone_group {
    name                 = local.caf_name.cosmos_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }
}
############################################################################################################################################################################
# Azure Speech

resource "azurerm_cognitive_account" "az_speech_account" {
  name                = local.caf_name.speech_account
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  kind                = "SpeechServices"
  sku_name            = "S0"

  # Speech services require generating a custom subdomain
  custom_subdomain_name = "${local.caf_name.speech_account}-${random_string.foundry_subdomain_suffix.result}"

}

resource "azurerm_private_endpoint" "speech_pe" {
  name                = local.caf_name.speech_private_endpoint
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = "psc-speech-${local.caf_base}"
    private_connection_resource_id = azurerm_cognitive_account.az_speech_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = local.caf_name.speech_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.cognitive_dns.id]
  }
}

############################################################################################################################################################################

#Azure Search

resource "azurerm_search_service" "azure_search_service" {
  name                = local.caf_name.search_service
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = azurerm_resource_group.az_rg.location
  sku                 = "standard"

  # Optional Configurations
  replica_count                 = 1
  partition_count               = 1
  public_network_access_enabled = true

}

resource "azurerm_private_endpoint" "search_pe" {
  name                = local.caf_name.search_private_endpoint
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = "psc-srch-${local.caf_base}"
    private_connection_resource_id = azurerm_search_service.azure_search_service.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = local.caf_name.search_private_dns_zone_group
    private_dns_zone_ids = [azurerm_private_dns_zone.search_dns.id]
  }
}