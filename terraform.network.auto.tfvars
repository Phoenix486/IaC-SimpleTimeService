virtual_network_address_space = ["10.0.16.0/20"]

# Network Security Groups with rules
network_security_groups = {
  pe = {
    name = "pe"
  }
  agw = {
    name = "agw"
    security_rules = {
      allow-management-inbound = {
        name                       = "allow-management-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      }
      allow-https = {
        name                       = "allow-https"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      allow-http = {
        name                       = "allow-http"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
  aks-node = {
    name = "aks-node"
  }
  aks-workload = {
    name = "aks-workload"
  }
  api-server = {
    name = "api-server"
    security_rules = {
      allow-api-server = {
        name                       = "allow-api-server"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    }
  }
}

# Subnets that will be linked to NSGs based on matching names
virtual_network_subnets = {
  private_endpoint_subnet = {
    name             = "pe" # No matching NSG
    address_prefixes = ["10.0.16.0/27"]
  }
  agw_subnet = {
    name             = "agw"
    address_prefixes = ["10.0.16.32/27"]
  }
  virtual_machine_subnet = {
    name             = "vm"
    address_prefixes = ["10.0.16.64/27"]
  }
  api_server_subnet = {
    name             = "api-server"
    address_prefixes = ["10.0.16.96/27"]
    delegations = [{
      name = "Microsoft.ContainerService/managedClusters"
      service_delegation = {
        name = "Microsoft.ContainerService/managedClusters"
      }
    }]
  }
  aks_node_subnet = {
    name             = "aks-node"
    address_prefixes = ["10.0.17.0/24"]
  }
  aks_workload_subnet = {
    name             = "aks-workload"
    address_prefixes = ["10.0.18.0/24"]
  }
}

private_dns_zones = {
  azure_monitor = {
    domain_name = "privatelink.monitor.azure.com"
  }
  ods_log_analytics = {
    domain_name = "privatelink.ods.opinsights.azure.com"
  }
  oms_log_analytics = {
    domain_name = "privatelink.oms.opinsights.azure.com"
  }
  automation = {
    domain_name = "privatelink.agentsvc.azure-automation.net"
  }
  storage = {
    domain_name = "privatelink.blob.core.windows.net"
  }
  key_vault = {
    domain_name = "privatelink.vault.azure.net"
  }
  container_registry = {
    domain_name = "privatelink.azurecr.io"
  }
  aks = {
    domain_name = "privatelink.eastus.azmk8s.io"
  }
}