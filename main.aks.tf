locals {
  aks_name                 = coalesce(var.aks_name, module.naming.kubernetes_cluster.name)
  node_resource_group_name = coalesce(var.node_resource_group_name, "${module.resource_group.name}-aks")

  aks_aad_profile = merge(var.aks_aad_profile, {
    tenant_id = data.azurerm_client_config.current.tenant_id
  })

  aks_api_server_access_profile = merge(var.aks_api_server_access_profile, {
    private_dns_zone = var.aks_api_server_access_profile.private_dns_zone_key != null ? module.private_dns_zone[var.aks_api_server_access_profile.private_dns_zone_key].resource_id : null
    subnet_id        = var.aks_api_server_access_profile.subnet_id != null ? var.aks_api_server_access_profile.subnet_id : (var.aks_api_server_access_profile.subnet_key != null ? module.virtual_network.subnets[var.aks_api_server_access_profile.subnet_key].resource_id : null)
  })

  agent_pools = {
    for key, node_pool in var.aks_agent_pools : key => merge(node_pool, {
      vnet_subnet_id = node_pool.vnet_subnet_id != null ? node_pool.vnet_subnet_id : (node_pool.vnet_subnet_key != null ? module.virtual_network.subnets[node_pool.vnet_subnet_key].resource_id : null)
      tags           = local.aks_tags
    })
  }

  aks_default_agent_pool = merge(var.aks_default_agent_pool, {
    vnet_subnet_id = var.aks_default_agent_pool.vnet_subnet_id != null ? var.aks_default_agent_pool.vnet_subnet_id : (var.aks_default_agent_pool.vnet_subnet_key != null ? module.virtual_network.subnets[var.aks_default_agent_pool.vnet_subnet_key].resource_id : null)
  })

  aks_managed_identities = var.aks_managed_identities.system_assigned ? {
    system_assigned            = true
    user_assigned_resource_ids = []
    } : {
    system_assigned            = false
    user_assigned_resource_ids = [for key in var.aks_managed_identities.user_assigned_identity_keys : module.managed_identity[key].resource_id]
  }

  aks_addon_profile_ingress_application_gateway = {
    enabled = var.aks_addon_profile_ingress_application_gateway.enabled
    config = var.aks_addon_profile_ingress_application_gateway.enabled ? {
      application_gateway_id = module.application_gateway.resource_id
    } : null
  }

  aks_tags = merge(local.tags, {
    "Resource_Type" = "Azure Kubernetes Service"
    "AKS_Name"      = local.aks_name
  })
}

module "azure_kubernetes_service" {
  source                                    = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version                                   = "0.5.2"
  location                                  = local.location
  name                                      = local.aks_name
  parent_id                                 = local.resource_group_id
  aad_profile                               = local.aks_aad_profile
  agent_pools                               = local.agent_pools
  auto_scaler_profile                       = var.aks_auto_scaler_profile
  agentpool_timeouts                        = var.aks_agentpool_timeouts
  api_server_access_profile                 = local.aks_api_server_access_profile
  default_agent_pool                        = local.aks_default_agent_pool
  disable_local_accounts                    = var.aks_disable_local_accounts
  fqdn_subdomain                            = local.aks_name
  managed_identities                        = local.aks_managed_identities
  network_profile                           = var.aks_network_profile
  addon_profile_ingress_application_gateway = local.aks_addon_profile_ingress_application_gateway
  sku                                       = var.aks_sku
  enable_telemetry                          = local.enable_telemetry
  tags                                      = local.aks_tags
}
