locals {
  agw_name           = coalesce(var.agw_name, module.naming.application_gateway.name)
  agw_public_ip_name = coalesce(var.agw_public_ip_name, "${local.agw_name}-pip")

  agw_gateway_ip_configuration = merge(var.agw_gateway_ip_configuration, {
    subnet_id = module.virtual_network.subnets["agw_subnet"].resource_id
    }
  )

  agw_public_ip_address_configuration = {
    public_ip_name = local.agw_public_ip_name
  }

  agw_managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.managed_identity["agw"].resource_id]
  }

  agw_tags = merge(local.tags, {
    "Resource_Type" = "Application Gateway"
    "Resource_Name" = local.agw_name
  })
}

module "application_gateway" {
  source                                = "Azure/avm-res-network-applicationgateway/azurerm"
  resource_group_name                   = module.resource_group.name
  location                              = local.location
  name                                  = local.agw_name
  sku                                   = var.agw_sku
  zones                                 = var.agw_zones
  managed_identities                    = local.agw_managed_identities
  autoscale_configuration               = var.agw_autoscale_configuration
  gateway_ip_configuration              = local.agw_gateway_ip_configuration
  frontend_ip_configuration_public_name = var.agw_frontend_ip_configuration_public_name
  frontend_ip_configuration_private     = var.agw_frontend_ip_configuration_private
  public_ip_address_configuration       = local.agw_public_ip_address_configuration
  frontend_ports                        = var.agw_frontend_ports
  waf_configuration                     = var.agw_waf_configuration
  backend_address_pools                 = var.agw_backend_address_pools
  backend_http_settings                 = var.agw_backend_http_settings
  http_listeners                        = var.agw_http_listeners
  app_gateway_waf_policy_resource_id    = var.agw_waf_policy_resource_id
  request_routing_rules                 = var.agw_request_routing_rules
  rewrite_rule_set                      = var.agw_rewrite_rule_set
  redirect_configuration                = var.agw_redirect_configuration
  ssl_policy                            = var.agw_ssl_policy
  ssl_profile                           = var.agw_ssl_profile
  diagnostic_settings                   = local.diagnostic_settings
  enable_telemetry                      = local.enable_telemetry
  tags                                  = local.agw_tags
}
