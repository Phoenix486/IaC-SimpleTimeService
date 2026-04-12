aks_sku = {
  name = "Base"
  tier = "Standard"
}

aks_aad_profile = {
  enable_azure_rbac      = true
  admin_group_object_ids = []
  managed                = true
}

aks_managed_identities = {
  system_assigned             = false
  user_assigned_identity_keys = ["aks"]
}

aks_default_agent_pool = {
  name                = "default"
  vm_size             = "standard_ec4ads_v5"
  enable_auto_scaling = true
  max_count           = 4
  min_count           = 2
  vnet_subnet_key     = "aks_node_subnet"
  node_taints         = ["CriticalAddonsOnly=true:NoSchedule"]
}

aks_agent_pools = {
  workload = {
    name                = "workload"
    vm_size             = "standard_ec4ads_v5"
    mode                = "User"
    enable_auto_scaling = true
    max_count           = 4
    min_count           = 2
    os_disk_size_gb     = 128
    vnet_subnet_key     = "aks_workload_subnet"
  }
}

aks_auto_scaler_profile = {
  expander                   = "random"
  scan_interval              = "20s"
  scale_down_unneeded_time   = "10m"
  scale_down_delay_after_add = "10m"
}

aks_network_profile = {
  dns_service_ip      = "10.10.200.10"
  service_cidr        = "10.10.200.0/24"
  pod_cidr            = "100.64.0.0/10"
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  network_dataplane   = "cilium"
  advanced_networking = {
    enabled = true
    observability = {
      enabled = true
    }
    security = {
      enabled                   = true
      advanced_network_policies = "FQDN"
    }
  }
}

aks_addon_profile_ingress_application_gateway = {
  enabled = true
  config  = null
}

aks_api_server_access_profile = {
  enable_private_cluster  = true
  enable_vnet_integration = true
  private_dns_zone_key    = "aks"
  subnet_key              = "api_server_subnet"
}

aks_disable_local_accounts = true
