variable "aks_name" {
  type        = string
  description = <<DESCRIPTION
The name of the resource.
DESCRIPTION
  default     = null

  validation {
    condition     = var.aks_name == null || length(var.aks_name) >= 1
    error_message = "aks_name must have a minimum length of 1."
  }
  validation {
    condition     = var.aks_name == null || length(var.aks_name) <= 63
    error_message = "aks_name must have a maximum length of 63."
  }
  validation {
    condition     = var.aks_name == null || can(regex("^[a-zA-Z0-9]$|^[a-zA-Z0-9][-_a-zA-Z0-9]{0,61}[a-zA-Z0-9]$", var.aks_name))
    error_message = "aks_name must match the pattern: ^[a-zA-Z0-9]$|^[a-zA-Z0-9][-_a-zA-Z0-9]{0,61}[a-zA-Z0-9]$."
  }
}

variable "node_resource_group_name" {
  type        = string
  description = <<DESCRIPTION
The name of the resource group to create and manage the cluster's agent pools in. If not specified, a new resource group will be created with the same name as the cluster resource group with '-aks' suffix.
DESCRIPTION
  default     = null

  validation {
    condition     = var.node_resource_group_name == null || length(var.node_resource_group_name) >= 1
    error_message = "node_resource_group_name must have a minimum length of 1."
  }
  validation {
    condition     = var.node_resource_group_name == null || length(var.node_resource_group_name) <= 90
    error_message = "node_resource_group_name must have a maximum length of 90."
  }
  validation {
    condition     = var.node_resource_group_name == null || can(regex("^[a-zA-Z0-9._()-]+$", var.node_resource_group_name))
    error_message = "node_resource_group_name must match the pattern: ^[a-zA-Z0-9._()-]+$."
  }
}

variable "aks_parent_id" {
  type        = string
  description = <<DESCRIPTION
The parent resource ID for this resource.
DESCRIPTION
  default     = null
}

variable "aks_aad_profile" {
  type = object({
    admin_group_object_ids = optional(list(string))
    client_app_id          = optional(string)
    enable_azure_rbac      = optional(bool)
    managed                = optional(bool)
    server_app_id          = optional(string)
    server_app_secret      = optional(string)
    tenant_id              = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
AADProfile specifies attributes for Azure Active Directory integration. For more details see [managed AAD on AKS](https://docs.microsoft.com/azure/aks/managed-aad).

- `admin_group_object_ids` - The list of AAD group object IDs that will have admin role of the cluster.
- `client_app_id` - (DEPRECATED) The client AAD application ID. Learn more at https://aka.ms/aks/aad-legacy.
- `enable_azure_rbac` - Whether to enable Azure RBAC for Kubernetes authorization.
- `managed` - Whether to enable managed AAD.
- `server_app_id` - (DEPRECATED) The server AAD application ID. Learn more at https://aka.ms/aks/aad-legacy.
- `server_app_secret` - (DEPRECATED) The server AAD application secret. Learn more at https://aka.ms/aks/aad-legacy.
- `tenant_id` - The AAD tenant ID to use for authentication. If not specified, will use the tenant of the deployment subscription.
DESCRIPTION
}

variable "aks_addon_profile_azure_policy" {
  type = object({
    config  = optional(map(string))
    enabled = bool
  })
  default = {
    enabled = false
  }
  description = "Azure Policy addon profile for the managed cluster. Not applicable for clusters in automatic mode."
}

variable "aks_addon_profile_confidential_computing" {
  type = object({
    config  = optional(map(string))
    enabled = bool
  })
  default     = null
  description = "Confidential Computing addon profile for the managed cluster."
}

variable "aks_addon_profile_ingress_application_gateway" {
  type = object({
    config = optional(object({
      application_gateway_id   = string
      application_gateway_name = optional(string)
      subnet_cidr              = optional(string)
      subnet_id                = optional(string)
    }))
    enabled = bool
  })
  default     = null
  description = "Ingress Application Gateway addon profile for the managed cluster."
}

variable "aks_addon_profile_key_vault_secrets_provider" {
  type = object({
    config = optional(object({
      enable_secret_rotation = optional(bool, false)
      rotation_poll_interval = optional(string)
    }))
    enabled = bool
  })
  default     = null
  description = "Key Vault Secrets Provider addon profile for the managed cluster."
}

variable "aks_addon_profile_oms_agent" {
  type = object({
    config = optional(object({
      log_analytics_workspace_resource_id = string
      use_aad_auth                        = optional(bool, false)
    }))
    enabled = bool
  })
  default     = null
  description = "OMS Agent addon profile for the managed cluster."

  validation {
    error_message = "If aks_addon_profile_oms_agent.enabled is true, then aks_addon_profile_oms_agent.config.log_analytics_workspace_resource_id must be set."
    condition     = var.aks_addon_profile_oms_agent == null || !(var.aks_addon_profile_oms_agent.enabled == true && (var.aks_addon_profile_oms_agent.config == null || var.aks_addon_profile_oms_agent.config.log_analytics_workspace_resource_id == ""))
  }
}

variable "aks_addon_profiles_extra" {
  type = map(object({
    config  = optional(map(string))
    enabled = bool
  }))
  default     = {}
  description = <<DESCRIPTION
Additional addon profiles of managed cluster add-on.
Will be merged with the predefined addon variables like `aks_addon_profile_oms_agent` and `aks_addon_profile_azure_policy`.

Map values:
- `config` - Key-value pairs for configuring an add-on.
- `enabled` - Whether the add-on is enabled or not.
- `identity` - The identity associated with the add-on.
DESCRIPTION
  nullable    = false
}

variable "aks_agentpool_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default = {
    create = "20m"
    delete = "20m"
    read   = "5m"
    update = "20m"
  }
  description = <<EOT
- `create` - (Defaults to 60 minutes) Used when creating the Kubernetes Cluster Node Pool.
- `delete` - (Defaults to 60 minutes) Used when deleting the Kubernetes Cluster Node Pool.
- `read` - (Defaults to 5 minutes) Used when retrieving the Kubernetes Cluster Node Pool.
- `update` - (Defaults to 60 minutes) Used when updating the Kubernetes Cluster Node Pool.
EOT
}

variable "aks_ai_toolchain_operator_profile" {
  type = object({
    enabled = optional(bool)
  })
  default     = null
  description = <<DESCRIPTION
When enabling the operator, a set of AKS managed CRDs and controllers will be installed in the cluster. The operator automates the deployment of OSS models for inference and/or training purposes. It provides a set of preset models and enables distributed inference against them.

- `enabled` - Whether to enable AI toolchain operator to the cluster. Indicates if AI toolchain operator  enabled or not.

DESCRIPTION
}

variable "aks_api_server_access_profile" {
  type = object({
    authorized_ip_ranges               = optional(list(string))
    disable_run_command                = optional(bool)
    enable_private_cluster             = optional(bool)
    enable_private_cluster_public_fqdn = optional(bool)
    enable_vnet_integration            = optional(bool)
    private_dns_zone                   = optional(string)
    private_dns_zone_key               = optional(string)
    subnet_id                          = optional(string)
    subnet_key                         = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Access profile for managed cluster API server.

- `authorized_ip_ranges` - The IP ranges authorized to access the Kubernetes API server. IP ranges are specified in CIDR format, e.g. 137.117.106.88/29. This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer. For more information see [API server authorized IP ranges](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges).
- `disable_run_command` - Whether to disable run command for the cluster or not.
- `enable_private_cluster` - Whether to create the cluster as a private cluster or not. For more details, see [Creating a private AKS cluster](https://docs.microsoft.com/azure/aks/private-clusters).
- `enable_private_cluster_public_fqdn` - Whether to create additional public FQDN for private cluster or not.
- `enable_vnet_integration` - Whether to enable apiserver vnet integration for the cluster or not. See aka.ms/AksVnetIntegration for more details.
- `private_dns_zone` - The private DNS zone mode for the cluster. The default is System. For more details see [configure private DNS zone](https://docs.microsoft.com/azure/aks/private-clusters#configure-private-dns-zone). Allowed values are 'system' and 'none'.
- `private_dns_zone_key` - The key for the private DNS zone to be used when `private_dns_zone` is set to 'none'. It is required when `private_dns_zone` is set to 'none'. The private DNS zone must be in the same subscription and region as the cluster.
- `subnet_id` - The subnet to be used when apiserver vnet integration is enabled. It is required when creating a new cluster with BYO Vnet, or when updating an existing cluster to enable apiserver vnet integration.
- `subnet_key` - The key for the subnet to be used when apiserver vnet integration is enabled. It is required when creating a new cluster with BYO Vnet, or when updating an existing cluster to enable apiserver vnet integration.
DESCRIPTION
}

variable "aks_auto_scaler_profile" {
  type = object({
    balance_similar_node_groups           = optional(string)
    daemonset_eviction_for_empty_nodes    = optional(bool)
    daemonset_eviction_for_occupied_nodes = optional(bool)
    expander                              = optional(string)
    ignore_daemonsets_utilization         = optional(bool)
    max_empty_bulk_delete                 = optional(string)
    max_graceful_termination_sec          = optional(string)
    max_node_provision_time               = optional(string)
    max_total_unready_percentage          = optional(string)
    new_pod_scale_up_delay                = optional(string)
    ok_total_unready_count                = optional(string)
    scale_down_delay_after_add            = optional(string)
    scale_down_delay_after_delete         = optional(string)
    scale_down_delay_after_failure        = optional(string)
    scale_down_unneeded_time              = optional(string)
    scale_down_unready_time               = optional(string)
    scale_down_utilization_threshold      = optional(string)
    scan_interval                         = optional(string)
    skip_nodes_with_local_storage         = optional(string)
    skip_nodes_with_system_pods           = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Parameters to be applied to the cluster-autoscaler when enabled

- `balance_similar_node_groups` - Detects similar node pools and balances the number of nodes between them. Valid values are 'true' and 'false'
- `daemonset_eviction_for_empty_nodes` - DaemonSet pods will be gracefully terminated from empty nodes. If set to true, all daemonset pods on empty nodes will be evicted before deletion of the node. If the daemonset pod cannot be evicted another node will be chosen for scaling. If set to false, the node will be deleted without ensuring that daemonset pods are deleted or evicted.
- `daemonset_eviction_for_occupied_nodes` - DaemonSet pods will be gracefully terminated from non-empty nodes. If set to true, all daemonset pods on occupied nodes will be evicted before deletion of the node. If the daemonset pod cannot be evicted another node will be chosen for scaling. If set to false, the node will be deleted without ensuring that daemonset pods are deleted or evicted.
- `expander` - The expander to use when scaling up. If not specified, the default is 'random'. See [expanders](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) for more information.
- `ignore_daemonsets_utilization` - Should CA ignore DaemonSet pods when calculating resource utilization for scaling down. If set to true, the resources used by daemonset will be taken into account when making scaling down decisions.
- `max_empty_bulk_delete` - The maximum number of empty nodes that can be deleted at the same time. This must be a positive integer. The default is 10.
- `max_graceful_termination_sec` - The maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. The default is 600.
- `max_node_provision_time` - The maximum time the autoscaler waits for a node to be provisioned. The default is '15m'. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `max_total_unready_percentage` - The maximum percentage of unready nodes in the cluster. After this percentage is exceeded, cluster autoscaler halts operations. The default is 45. The maximum is 100 and the minimum is 0.
- `new_pod_scale_up_delay` - Ignore unscheduled pods before they're a certain age. For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. The default is '0s'. Values must be an integer followed by a unit ('s' for seconds, 'm' for minutes, 'h' for hours, etc).
- `ok_total_unready_count` - The number of allowed unready nodes, irrespective of max-total-unready-percentage. This must be an integer. The default is 3.
- `scale_down_delay_after_add` - How long after scale up that scale down evaluation resumes. The default is '10m'. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `scale_down_delay_after_delete` - How long after node deletion that scale down evaluation resumes. The default is the scan-interval. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `scale_down_delay_after_failure` - How long after scale down failure that scale down evaluation resumes. The default is '3m'. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `scale_down_unneeded_time` - How long a node should be unneeded before it is eligible for scale down. The default is '10m'. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `scale_down_unready_time` - How long an unready node should be unneeded before it is eligible for scale down. The default is '20m'. Values must be an integer followed by an 'm'. No unit of time other than minutes (m) is supported.
- `scale_down_utilization_threshold` - Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. The default is '0.5'.
- `scan_interval` - How often cluster is reevaluated for scale up or down. The default is '10'. Values must be an integer number of seconds.
- `skip_nodes_with_local_storage` - If cluster autoscaler will skip deleting nodes with pods with local storage, for example, EmptyDir or HostPath. The default is true.
- `skip_nodes_with_system_pods` - If cluster autoscaler will skip deleting nodes with pods from kube-system (except for DaemonSet or mirror pods). The default is true.

DESCRIPTION

  validation {
    condition     = var.aks_auto_scaler_profile == null || var.aks_auto_scaler_profile.expander == null || contains(["least-waste", "most-pods", "priority", "random"], var.aks_auto_scaler_profile.expander)
    error_message = "aks_auto_scaler_profile.expander must be one of: [\"least-waste\", \"most-pods\", \"priority\", \"random\"]."
  }
}

variable "aks_auto_upgrade_profile" {
  type = object({
    node_os_upgrade_channel = optional(string, "NodeImage")
    upgrade_channel         = optional(string, "none")
  })
  default     = null
  description = <<DESCRIPTION
Auto upgrade profile for a managed cluster.

- `node_os_upgrade_channel` - Node OS Upgrade Channel. Manner in which the OS on your nodes is updated. The default is NodeImage.
- `upgrade_channel` - The upgrade channel for auto upgrade. The default is 'none'. For more information see [setting the AKS cluster auto-upgrade channel](https://docs.microsoft.com/azure/aks/upgrade-cluster#set-auto-upgrade-channel).

DESCRIPTION

  validation {
    condition     = var.aks_auto_upgrade_profile == null || var.aks_auto_upgrade_profile.node_os_upgrade_channel == null || contains(["NodeImage", "None", "SecurityPatch", "Unmanaged"], var.aks_auto_upgrade_profile.node_os_upgrade_channel)
    error_message = "aks_auto_upgrade_profile.node_os_upgrade_channel must be one of: [\"NodeImage\", \"None\", \"SecurityPatch\", \"Unmanaged\"]."
  }
  validation {
    condition     = var.aks_auto_upgrade_profile == null || var.aks_auto_upgrade_profile.upgrade_channel == null || contains(["node-image", "none", "patch", "rapid", "stable"], var.aks_auto_upgrade_profile.upgrade_channel)
    error_message = "aks_auto_upgrade_profile.upgrade_channel must be one of: [\"node-image\", \"none\", \"patch\", \"rapid\", \"stable\"]."
  }
}

variable "aks_azure_monitor_profile" {
  type = object({
    metrics = optional(object({
      enabled = bool
      kube_state_metrics = optional(object({
        metric_annotations_allow_list = optional(string)
        metric_labels_allowlist       = optional(string)
      }))
    }))
  })
  default     = null
  description = <<DESCRIPTION
Azure Monitor addon profiles for monitoring the managed cluster.

- `metrics` - Metrics profile for the Azure Monitor managed service for Prometheus addon. Collect out-of-the-box Kubernetes infrastructure metrics to send to an Azure Monitor Workspace and configure additional scraping for custom targets. See aka.ms/AzureManagedPrometheus for an overview.
  - `enabled` - Whether to enable or disable the Azure Managed Prometheus addon for Prometheus monitoring. See aka.ms/AzureManagedPrometheus-aks-enable for details on enabling and disabling.
  - `kube_state_metrics` - Kube State Metrics profile for the Azure Managed Prometheus addon. These optional settings are for the kube-state-metrics pod that is deployed with the addon. See aka.ms/AzureManagedPrometheus-optional-parameters for details.
    - `metric_annotations_allow_list` - Comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric (Example: 'namespaces=[kubernetes.io/team,...],pods=[kubernetes.io/team],...'). By default the metric contains only resource name and namespace labels.
    - `metric_labels_allowlist` - Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric (Example: 'namespaces=[k8s-label-1,k8s-label-n,...],pods=[app],...'). By default the metric contains only resource name and namespace labels.

DESCRIPTION
}

variable "aks_bootstrap_profile" {
  type = object({
    artifact_source       = optional(string)
    container_registry_id = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
The bootstrap profile.

- `artifact_source` - The artifact source. The source where the artifacts are downloaded from.
- `container_registry_id` - The resource Id of Azure Container Registry. The registry must have private network access, premium SKU and zone redundancy.

DESCRIPTION

  validation {
    condition     = var.aks_bootstrap_profile == null || var.aks_bootstrap_profile.artifact_source == null || contains(["Cache", "Direct"], var.aks_bootstrap_profile.artifact_source)
    error_message = "aks_bootstrap_profile.artifact_source must be one of: [\"Cache\", \"Direct\"]."
  }
}

variable "aks_cluster_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<EOT
- `create` - (Defaults to 60 minutes) Used when creating the Kubernetes Cluster Node Pool.
- `delete` - (Defaults to 60 minutes) Used when deleting the Kubernetes Cluster Node Pool.
- `read` - (Defaults to 5 minutes) Used when retrieving the Kubernetes Cluster Node Pool.
- `update` - (Defaults to 60 minutes) Used when updating the Kubernetes Cluster Node Pool.
EOT
}

variable "aks_create_agentpools_before_destroy" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
When enabled, allows Terraform to create new agent pools before destroying the old ones during updates that require replacement. This can help reduce downtime during updates but may incur additional costs due to temporarily having more resources allocated.
DESCRIPTION
}

variable "aks_default_agent_pool" {
  type = object({
    availability_zones            = optional(list(string))
    capacity_reservation_group_id = optional(string)
    count_of                      = optional(number, 3)
    creation_data = optional(object({
      source_resource_id = optional(string)
    }))
    enable_auto_scaling       = optional(bool)
    enable_encryption_at_host = optional(bool)
    enable_fips               = optional(bool)
    enable_node_public_ip     = optional(bool)
    enable_ultra_ssd          = optional(bool)
    gateway_profile = optional(object({
      public_ip_prefix_size = optional(number)
    }))
    gpu_instance_profile = optional(string)
    gpu_profile = optional(object({
      driver = optional(string)
    }))
    host_group_id = optional(string)
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_files   = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota             = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      fail_swap_on              = optional(bool)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pids              = optional(number)
      topology_manager_policy   = optional(string)
    }))
    kubelet_disk_type = optional(string)
    linux_os_config = optional(object({
      swap_file_size_mb = optional(number)
      sysctls = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range       = optional(string)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_ipv4_tcpkeepalive_intvl        = optional(number)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(string)
    }))
    local_dns_profile = optional(object({
      kube_dns_overrides = optional(map(object({
        cache_duration_in_seconds       = optional(number)
        forward_destination             = optional(string)
        forward_policy                  = optional(string)
        max_concurrent                  = optional(number)
        protocol                        = optional(string)
        query_logging                   = optional(string)
        serve_stale                     = optional(string)
        serve_stale_duration_in_seconds = optional(number)
      })))
      vnet_dns_overrides = optional(map(object({
        cache_duration_in_seconds       = optional(number)
        forward_destination             = optional(string)
        forward_policy                  = optional(string)
        max_concurrent                  = optional(number)
        protocol                        = optional(string)
        query_logging                   = optional(string)
        serve_stale                     = optional(string)
        serve_stale_duration_in_seconds = optional(number)
      })))
    }))
    max_count          = optional(number)
    max_pods           = optional(number)
    message_of_the_day = optional(string)
    min_count          = optional(number)
    mode               = optional(string)
    name               = optional(string, "systempool")
    network_profile = optional(object({
      allowed_host_ports = optional(list(object({
        port_end   = optional(number)
        port_start = optional(number)
        protocol   = optional(string)
      })))
      application_security_groups = optional(list(string))
      node_public_ip_tags = optional(list(object({
        ip_tag_type = optional(string)
        tag         = optional(string)
      })))
    }))
    node_labels              = optional(map(string))
    node_public_ip_prefix_id = optional(string)
    node_taints              = optional(list(string))
    orchestrator_version     = optional(string)
    os_disk_size_gb          = optional(number)
    os_disk_type             = optional(string)
    os_sku                   = optional(string)
    output_data_only         = optional(bool)
    pod_ip_allocation_mode   = optional(string)
    pod_subnet_id            = optional(string)
    pod_subnet_key           = optional(string)
    power_state = optional(object({
      code = optional(string)
    }))
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string)
    scale_set_eviction_policy    = optional(string)
    scale_set_priority           = optional(string)
    security_profile = optional(object({
      enable_secure_boot = optional(bool)
      enable_vtpm        = optional(bool)
      ssh_access         = optional(string)
    }))
    spot_max_price = optional(number)
    status         = optional(object({}))
    tags           = optional(map(string))
    type           = optional(string)
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      max_surge                     = optional(string)
      max_unavailable               = optional(string)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    }))
    virtual_machines_profile = optional(object({
      scale = optional(object({
        manual = optional(list(object({
          count = optional(number)
          size  = optional(string)
        })))
      }))
    }))
    vm_size         = optional(string)
    vnet_subnet_id  = optional(string)
    vnet_subnet_key = optional(string)
    windows_profile = optional(object({
      disable_outbound_nat = optional(bool)
    }))
    workload_runtime = optional(string)
  })
  default     = {}
  description = <<DESCRIPTION
Configuration block for the default agent pool of the Kubernetes cluster.
See `var.agent_pools` for details on the available options.

Note that:
- The `os_type` and `mode` options are not available here and are automatically set to `Linux` and `System` respectively.
- The default node count (`count_of`) is set to `3` if not specified.
- The default name is set to `systempool` if not specified.
- It is not supported to rename the default agent pool after creation.
DESCRIPTION
  nullable    = false
}

variable "aks_diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<-DESCRIPTION
  A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.aks_diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.aks_diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "aks_disable_local_accounts" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
If local accounts should be disabled on the Managed Cluster. If set to true, getting static credentials will be disabled for this cluster. This must only be used on Managed Clusters that are AAD enabled. For more details see [disable local accounts](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts-preview).
DESCRIPTION
  nullable    = false
}

variable "aks_disk_encryption_set_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The Resource ID of the disk encryption set to use for enabling encryption at rest.
This is of the form: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/diskEncryptionSets/{encryptionSetName}'
DESCRIPTION
}

variable "aks_dns_prefix" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The DNS prefix of the Managed Cluster. This cannot be updated once the Managed Cluster has been created.
If not specified, a random DNS prefix will be generated.
This property is mutually exclusive with `fqdn_subdomain`. When `fqdn_subdomain` is set, `dns_prefix` is automatically omitted.
DESCRIPTION
}

variable "aks_enable_rbac" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
Whether to enable Kubernetes Role-Based Access Control.
DESCRIPTION
}

variable "aks_identity_profile" {
  type = map(object({
    resource_id = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
The user identity associated with the managed cluster. This identity will be used by the kubelet. Only one user assigned identity is allowed. The only accepted key is "kubeletidentity", with value of "resourceId": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}".

Map values:
- `resource_id` - The resource ID of the user assigned identity.

Only supported with clusters that are assigned a user managed identity.
The control plane managed identity must be assigned 'Managed Identity Operator' role on the user assigned identity.
DESCRIPTION

  validation {
    error_message = "The only accepted key for identity_profile is 'kubeletidentity'."
    condition     = var.aks_identity_profile == null || alltrue([for k in keys(var.aks_identity_profile) : k == "kubeletidentity"])
  }
  validation {
    error_message = "When kublet identity is specified in identity_profile, managed_identities.user_assigned_resource_ids must be configured."
    condition     = var.aks_identity_profile == null || !contains(keys(var.aks_identity_profile), "kubeletidentity") || (var.aks_managed_identities != null && length(var.aks_managed_identities.user_assigned_resource_ids) == 1)
  }
}

variable "aks_ingress_profile" {
  type = object({
    web_app_routing = optional(object({
      dns_zone_resource_ids = optional(list(string))
      enabled               = optional(bool)
      nginx = optional(object({
        default_ingress_controller_type = optional(string)
      }))
    }))
  })
  default     = null
  description = <<DESCRIPTION
Ingress profile for the container service cluster.

- `web_app_routing` - Application Routing add-on settings for the ingress profile.
  - `dns_zone_resource_ids` - Resource IDs of the DNS zones to be associated with the Application Routing add-on. Used only when Application Routing add-on is enabled. Public and private DNS zones can be in different resource groups, but all public DNS zones must be in the same resource group and all private DNS zones must be in the same resource group.
  - `enabled` - Whether to enable the Application Routing add-on.
  - `nginx` - The nginx property.
    - `default_ingress_controller_type` - Ingress type for the default NginxIngressController custom resource

DESCRIPTION
}

variable "aks_kind" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The kind of the managed cluster. This is only used to distinguish different types of managed clusters. Possible values are 'Base' or can be left null. This property is used internally.
DESCRIPTION
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The version of Kubernetes specified by the user. Both patch version <major.minor.patch> (e.g. 1.20.13) and <major.minor> (e.g. 1.20) are supported. When <major.minor> is specified, the latest supported GA patch version is chosen automatically. Updating the cluster with the same <major.minor> once it has been created (e.g. 1.14.x -> 1.14) will not trigger an upgrade, even if a newer patch version is available. When you upgrade a supported AKS cluster, Kubernetes minor versions cannot be skipped. All upgrades must be performed sequentially by major version number. For example, upgrades between 1.14.x -> 1.15.x or 1.15.x -> 1.16.x are allowed, however 1.14.x -> 1.16.x is not allowed. See [upgrading an AKS cluster](https://docs.microsoft.com/azure/aks/upgrade-cluster) for more details.
DESCRIPTION
}

variable "aks_linux_profile" {
  type = object({
    admin_username = string
    ssh = object({
      public_keys = list(object({
        key_data = string
      }))
    })
  })
  default     = null
  description = <<DESCRIPTION
Profile for Linux VMs in the container service cluster.

- `admin_username` - The administrator username to use for Linux VMs.
- `ssh` - SSH configuration for Linux-based VMs running on Azure.
  - `public_keys` - The list of SSH public keys used to authenticate with Linux-based VMs. A maximum of 1 key may be specified.

DESCRIPTION

  validation {
    condition     = var.aks_linux_profile == null || can(regex("^[A-Za-z][-A-Za-z0-9_]*$", var.aks_linux_profile.admin_username))
    error_message = "aks_linux_profile.admin_username must match the pattern: ^[A-Za-z][-A-Za-z0-9_]*$."
  }
}

variable "aks_managed_identities" {
  type = object({
    system_assigned             = optional(bool, false)
    user_assigned_resource_ids  = optional(set(string), [])
    user_assigned_identity_keys = optional(set(string), [])
  })
  default = {
    system_assigned = true
  }
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource.
For this resource we enable system assigned identity by default,
This allows the cluster to support deployment of managed resources.
If you don't want to use managed identity, then you must supply `service_principal_profile`.
Using managed identity is stringly recommended over service principal.
DESCRIPTION
  nullable    = false
}

variable "aks_network_profile" {
  type = object({
    advanced_networking = optional(object({
      enabled = optional(bool)
      observability = optional(object({
        enabled = optional(bool)
      }))
      security = optional(object({
        advanced_network_policies = optional(string)
        enabled                   = optional(bool)
      }))
    }))
    dns_service_ip = optional(string)
    ip_families    = optional(list(string))
    load_balancer_profile = optional(object({
      allocated_outbound_ports                = optional(number)
      backend_pool_type                       = optional(string)
      enable_multiple_standard_load_balancers = optional(bool)
      idle_timeout_in_minutes                 = optional(number)
      managed_outbound_ips = optional(object({
        count       = optional(number)
        count_i_pv6 = optional(number)
      }))
      outbound_ip_prefixes = optional(object({
        public_ip_prefixes = optional(list(object({
          id = optional(string)
        })))
      }))
      outbound_ips = optional(object({
        public_ips = optional(list(object({
          id = optional(string)
        })))
      }))
    }))
    load_balancer_sku = optional(string)
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes = optional(number)
      managed_outbound_ip_profile = optional(object({
        count = optional(number)
      }))
    }))
    network_dataplane   = optional(string)
    network_mode        = optional(string)
    network_plugin      = optional(string)
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    outbound_type       = optional(string)
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    static_egress_gateway_profile = optional(object({
      enabled = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Profile of network configuration.

- `advanced_networking` - Advanced Networking profile for enabling observability and security feature suite on a cluster. For more information see aka.ms/aksadvancednetworking.
  - `enabled` - Indicates the enablement of Advanced Networking functionalities of observability and security on AKS clusters. When this is set to true, all observability and security features will be set to enabled unless explicitly disabled. If not specified, the default is false.
  - `observability` - Observability profile to enable advanced network metrics and flow logs with historical contexts.
    - `enabled` - Indicates the enablement of Advanced Networking observability functionalities on clusters.
  - `security` - Security profile to enable security features on cilium based cluster.
    - `advanced_network_policies` - Enable advanced network policies. This allows users to configure Layer 7 network policies (FQDN, HTTP, Kafka). Policies themselves must be configured via the Cilium Network Policy resources, see https://docs.cilium.io/en/latest/security/policy/index.html. This can be enabled only on cilium-based clusters. If not specified, the default value is FQDN if security.enabled is set to true.
    - `enabled` - This feature allows user to configure network policy based on DNS (FQDN) names. It can be enabled only on cilium based clusters. If not specified, the default is false.
- `dns_service_ip` - An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.
- `ip_families` - The IP families used to specify IP versions available to the cluster. IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4. For dual-stack, the expected values are IPv4 and IPv6.
- `load_balancer_profile` - Profile of the managed cluster load balancer.
  - `allocated_outbound_ports` - The desired number of allocated SNAT ports per VM. Allowed values are in the range of 0 to 64000 (inclusive). The default value is 0 which results in Azure dynamically allocating ports.
  - `backend_pool_type` - The type of the managed inbound Load Balancer BackendPool.
  - `enable_multiple_standard_load_balancers` - Enable multiple standard load balancers per AKS cluster or not.
  - `idle_timeout_in_minutes` - Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive). The default value is 30 minutes.
  - `managed_outbound_ips` - Desired managed outbound IPs for the cluster load balancer.
    - `count` - The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.
    - `count_i_pv6` - The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack.
  - `outbound_ip_prefixes` - Desired outbound IP Prefix resources for the cluster load balancer.
    - `public_ip_prefixes` - A list of public IP prefix resources.
  - `outbound_ips` - Desired outbound IP resources for the cluster load balancer.
    - `public_ips` - A list of public IP resources.
- `load_balancer_sku` - The load balancer sku for the managed cluster. The default is 'standard'. See [Azure Load Balancer SKUs](https://docs.microsoft.com/azure/load-balancer/skus) for more information about the differences between load balancer SKUs.
- `nat_gateway_profile` - Profile of the managed cluster NAT gateway.
  - `idle_timeout_in_minutes` - Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive). The default value is 4 minutes.
  - `managed_outbound_ip_profile` - Profile of the managed outbound IP resources of the managed cluster.
    - `count` - The desired number of outbound IPs created/managed by Azure. Allowed values must be in the range of 1 to 16 (inclusive). The default value is 1.
- `network_dataplane` - Network dataplane used in the Kubernetes cluster.
- `network_mode` - The network mode Azure CNI is configured with. This cannot be specified if networkPlugin is anything other than 'azure'.
- `network_plugin` - Network plugin used for building the Kubernetes network.
- `network_plugin_mode` - The mode the network plugin should use.
- `network_policy` - Network policy used for building the Kubernetes network.
- `outbound_type` - The outbound (egress) routing method. This can only be set at cluster creation time and cannot be changed later. For more information see [egress outbound type](https://docs.microsoft.com/azure/aks/egress-outboundtype).
- `pod_cidr` - A CIDR notation IP range from which to assign pod IPs when kubenet is used.
- `pod_cidrs` - The CIDR notation IP ranges from which to assign pod IPs. One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking.
- `service_cidr` - A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.
- `service_cidrs` - The CIDR notation IP ranges from which to assign service cluster IPs. One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking. They must not overlap with any Subnet IP ranges.
- `static_egress_gateway_profile` - The Static Egress Gateway addon configuration for the cluster.
  - `enabled` - Enable Static Egress Gateway addon. Indicates if Static Egress Gateway addon is enabled or not.

DESCRIPTION

  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.dns_service_ip == null || can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.aks_network_profile.dns_service_ip))
    error_message = "aks_network_profile.dns_service_ip must match the pattern: ^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.load_balancer_sku == null || contains(["basic", "standard"], var.aks_network_profile.load_balancer_sku)
    error_message = "aks_network_profile.load_balancer_sku must be one of: [\"basic\", \"standard\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.network_dataplane == null || contains(["azure", "cilium"], var.aks_network_profile.network_dataplane)
    error_message = "aks_network_profile.network_dataplane must be one of: [\"azure\", \"cilium\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.network_mode == null || contains(["bridge", "transparent"], var.aks_network_profile.network_mode)
    error_message = "aks_network_profile.network_mode must be one of: [\"bridge\", \"transparent\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.network_plugin == null || contains(["azure", "kubenet", "none"], var.aks_network_profile.network_plugin)
    error_message = "aks_network_profile.network_plugin must be one of: [\"azure\", \"kubenet\", \"none\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.network_plugin_mode == null || contains(["overlay"], var.aks_network_profile.network_plugin_mode)
    error_message = "aks_network_profile.network_plugin_mode must be one of: [\"overlay\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.network_policy == null || contains(["azure", "calico", "cilium", "none"], var.aks_network_profile.network_policy)
    error_message = "aks_network_profile.network_policy must be one of: [\"azure\", \"calico\", \"cilium\", \"none\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.outbound_type == null || contains(["loadBalancer", "managedNATGateway", "none", "userAssignedNATGateway", "userDefinedRouting"], var.aks_network_profile.outbound_type)
    error_message = "aks_network_profile.outbound_type must be one of: [\"loadBalancer\", \"managedNATGateway\", \"none\", \"userAssignedNATGateway\", \"userDefinedRouting\"]."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.pod_cidr == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.aks_network_profile.pod_cidr))
    error_message = "aks_network_profile.pod_cidr must match the pattern: ^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$."
  }
  validation {
    condition     = var.aks_network_profile == null || var.aks_network_profile.service_cidr == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.aks_network_profile.service_cidr))
    error_message = "aks_network_profile.service_cidr must match the pattern: ^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$."
  }
}

variable "aks_node_provisioning_profile" {
  type = object({
    default_node_pools = optional(string)
    mode               = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
The nodeProvisioningProfile of the resource.

- `default_node_pools` - The set of default Karpenter NodePools (CRDs) configured for node provisioning. This field has no effect unless mode is 'Auto'. Warning: Changing this from Auto to None on an existing cluster will cause the default Karpenter NodePools to be deleted, which will drain and delete the nodes associated with those pools. It is strongly recommended to not do this unless there are idle nodes ready to take the pods evicted by that action. If not specified, the default is Auto. For more information see aka.ms/aks/nap#node-pools.
- `mode` - The node provisioning mode. If not specified, the default is Manual.

DESCRIPTION

  validation {
    condition     = var.aks_node_provisioning_profile == null || var.aks_node_provisioning_profile.default_node_pools == null || contains(["Auto", "None"], var.aks_node_provisioning_profile.default_node_pools)
    error_message = "aks_node_provisioning_profile.default_node_pools must be one of: [\"Auto\", \"None\"]."
  }
  validation {
    condition     = var.aks_node_provisioning_profile == null || var.aks_node_provisioning_profile.mode == null || contains(["Auto", "Manual"], var.aks_node_provisioning_profile.mode)
    error_message = "aks_node_provisioning_profile.mode must be one of: [\"Auto\", \"Manual\"]."
  }
}

variable "aks_node_resource_group" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The name of the resource group containing agent pool nodes.
DESCRIPTION
}

variable "aks_node_resource_group_profile" {
  type = object({
    restriction_level = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Node resource group lockdown profile for a managed cluster.

- `restriction_level` - The restriction level applied to the cluster's node resource group. If not specified, the default is 'Unrestricted'

DESCRIPTION

  validation {
    condition     = var.aks_node_resource_group_profile == null || var.aks_node_resource_group_profile.restriction_level == null || contains(["ReadOnly", "Unrestricted"], var.aks_node_resource_group_profile.restriction_level)
    error_message = "aks_node_resource_group_profile.restriction_level must be one of: [\"ReadOnly\", \"Unrestricted\"]."
  }
}

variable "aks_oidc_issuer_profile" {
  type = object({
    enabled = optional(bool)
  })
  default     = null
  description = <<DESCRIPTION
The OIDC issuer profile of the Managed Cluster.

- `enabled` - Whether the OIDC issuer is enabled.

DESCRIPTION
}

variable "aks_pod_identity_profile" {
  type = object({
    allow_network_plugin_kubenet = optional(bool)
    enabled                      = optional(bool)
    user_assigned_identities = optional(list(object({
      binding_selector = optional(string)
      identity = object({
        client_id   = optional(string)
        object_id   = optional(string)
        resource_id = optional(string)
      })
      name      = string
      namespace = string
    })))
    user_assigned_identity_exceptions = optional(list(object({
      name       = string
      namespace  = string
      pod_labels = map(string)
    })))
  })
  default     = null
  description = <<DESCRIPTION
The pod identity profile of the Managed Cluster. See [use AAD pod identity](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity) for more details on pod identity integration.

- `allow_network_plugin_kubenet` - Whether pod identity is allowed to run on clusters with Kubenet networking. Running in Kubenet is disabled by default due to the security related nature of AAD Pod Identity and the risks of IP spoofing. See [using Kubenet network plugin with AAD Pod Identity](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity#using-kubenet-network-plugin-with-azure-active-directory-pod-managed-identities) for more information.
- `enabled` - Whether the pod identity addon is enabled.
- `user_assigned_identities` - The pod identities to use in the cluster.
- `user_assigned_identity_exceptions` - The pod identity exceptions to allow.

DESCRIPTION
}

variable "aks_private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource.
DESCRIPTION
  nullable    = false
}

variable "aks_private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
Whether to manage private DNS zone groups with this module.
DESCRIPTION
  nullable    = false
}

variable "aks_private_link_resources" {
  type = list(object({
    group_id         = optional(string)
    id               = optional(string)
    name             = optional(string)
    required_members = optional(list(string))
    type             = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
Private link resources associated with the cluster.
DESCRIPTION
}

variable "aks_public_network_access" {
  type        = string
  default     = null
  description = <<DESCRIPTION
PublicNetworkAccess of the managedCluster. Allow or deny public network access for AKS
DESCRIPTION

  validation {
    condition     = var.aks_public_network_access == null || contains(["Disabled", "Enabled"], var.aks_public_network_access)
    error_message = "aks_public_network_access must be one of: [\"Disabled\", \"Enabled\"]."
  }
}

variable "aks_role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "aks_security_profile" {
  type = object({
    azure_key_vault_kms = optional(object({
      enabled                  = optional(bool)
      key_id                   = optional(string)
      key_vault_network_access = optional(string)
      key_vault_resource_id    = optional(string)
    }))
    custom_ca_trust_certificates = optional(list(string))
    defender = optional(object({
      log_analytics_workspace_resource_id = optional(string)
      security_monitoring = optional(object({
        enabled = optional(bool)
      }))
    }))
    image_cleaner = optional(object({
      enabled        = optional(bool)
      interval_hours = optional(number)
    }))
    workload_identity = optional(object({
      enabled = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Security profile for the container service cluster.

- `azure_key_vault_kms` - Azure Key Vault key management service settings for the security profile.
  - `enabled` - Whether to enable Azure Key Vault key management service. The default is false.
  - `key_id` - Identifier of Azure Key Vault key. See [key identifier format](https://docs.microsoft.com/en-us/azure/key-vault/general/about-keys-secrets-certificates#vault-name-and-object-name) for more details. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier. When Azure Key Vault key management service is disabled, leave the field empty.
  - `key_vault_network_access` - Network access of the key vault. Network access of key vault. The possible values are `Public` and `Private`. `Public` means the key vault allows public access from all networks. `Private` means the key vault disables public access and enables private link. The default value is `Public`.
  - `key_vault_resource_id` - Resource ID of key vault. When keyVaultNetworkAccess is `Private`, this field is required and must be a valid resource ID. When keyVaultNetworkAccess is `Public`, leave the field empty.
- `custom_ca_trust_certificates` - The list of base64 encoded certificate strings that will be added to the node trust store. At most 10 certificates can be provided. Certificates will be added to trust stores of all the nodes in the cluster. If updated, the new list of certificates will be installed in the trust store in place of the old certificates. For node pools of VMSS type, updating the value of this field will result in nodes being reimaged.
- `defender` - Microsoft Defender settings for the security profile.
  - `log_analytics_workspace_resource_id` - Resource ID of the Log Analytics workspace to be associated with Microsoft Defender. When Microsoft Defender is enabled, this field is required and must be a valid workspace resource ID. When Microsoft Defender is disabled, leave the field empty.
  - `security_monitoring` - Microsoft Defender settings for the security profile threat detection.
    - `enabled` - Whether to enable Defender threat detection
- `image_cleaner` - Image Cleaner removes unused images from nodes, freeing up disk space and helping to reduce attack surface area. Here are settings for the security profile.
  - `enabled` - Whether to enable Image Cleaner on AKS cluster.
  - `interval_hours` - Image Cleaner scanning interval in hours.
- `workload_identity` - Workload identity settings for the security profile.
  - `enabled` - Whether to enable workload identity.

DESCRIPTION

  validation {
    condition     = var.aks_security_profile == null || var.aks_security_profile.custom_ca_trust_certificates == null || length(var.aks_security_profile.custom_ca_trust_certificates) <= 10
    error_message = "aks_security_profile.custom_ca_trust_certificates must have at most 10 item(s)."
  }
}

variable "aks_service_mesh_profile" {
  type = object({
    istio = optional(object({
      certificate_authority = optional(object({
        plugin = optional(object({
          cert_chain_object_name = optional(string)
          cert_object_name       = optional(string)
          key_object_name        = optional(string)
          key_vault_id           = optional(string)
          root_cert_object_name  = optional(string)
        }))
      }))
      components = optional(object({
        egress_gateways = optional(list(object({
          enabled                    = bool
          gateway_configuration_name = optional(string)
          name                       = string
          namespace                  = optional(string)
        })))
        ingress_gateways = optional(list(object({
          enabled = bool
          mode    = string
        })))
      }))
      revisions = optional(list(string))
    }))
    mode = string
  })
  default     = null
  description = <<DESCRIPTION
Service mesh profile for a managed cluster.

- `istio` - Istio service mesh configuration.
  - `certificate_authority` - Istio Service Mesh Certificate Authority (CA) configuration. For now, we only support plugin certificates as described here https://aka.ms/asm-plugin-ca
    - `plugin` - Plugin certificates information for Service Mesh.
      - `cert_chain_object_name` - Certificate chain object name in Azure Key Vault.
      - `cert_object_name` - Intermediate certificate object name in Azure Key Vault.
      - `key_object_name` - Intermediate certificate private key object name in Azure Key Vault.
      - `key_vault_id` - The resource ID of the Key Vault.
      - `root_cert_object_name` - Root certificate object name in Azure Key Vault.
  - `components` - Istio components configuration.
    - `egress_gateways` - Istio egress gateways.
    - `ingress_gateways` - Istio ingress gateways.
  - `revisions` - The list of revisions of the Istio control plane. When an upgrade is not in progress, this holds one value. When canary upgrade is in progress, this can only hold two consecutive values. For more information, see: https://learn.microsoft.com/en-us/azure/aks/istio-upgrade
- `mode` - Mode of the service mesh.

DESCRIPTION

  validation {
    condition     = var.aks_service_mesh_profile == null || contains(["Disabled", "Istio"], var.aks_service_mesh_profile.mode)
    error_message = "aks_service_mesh_profile.mode must be one of: [\"Disabled\", \"Istio\"]."
  }
}

variable "aks_service_principal_profile" {
  type = object({
    client_id = string
    secret    = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Information about a service principal identity for the cluster to use for manipulating Azure APIs.

- `client_id` - The ID for the service principal.
- `secret` - The secret password associated with the service principal in plain text.

DESCRIPTION
}

variable "aks_sku" {
  type = object({
    name = optional(string)
    tier = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
The SKU of a Managed Cluster.

- `name` - The name of a managed cluster SKU. Valid values are 'Automatic' and 'Base'.
- `tier` - The tier of a managed cluster SKU. Valid values are 'Free', 'Standard', and 'Premium'.

NOTE:
When deploying an Automatic SKU cluster, only the allowable API properties will be included in the request.
Any remaining properties not supported by Automatic SKU will be ignored.
See <https://learn.microsoft.com/azure/aks/intro-aks-automatic#aks-automatic-and-standard-feature-comparison> for more details.
DESCRIPTION

  validation {
    condition     = var.aks_sku == null || var.aks_sku.name == null || contains(["Automatic", "Base"], var.aks_sku.name)
    error_message = "aks_sku.name must be one of: [\"Automatic\", \"Base\"]."
  }
  validation {
    condition     = var.aks_sku == null || var.aks_sku.tier == null || contains(["Free", "Premium", "Standard"], var.aks_sku.tier)
    error_message = "aks_sku.tier must be one of: [\"Free\", \"Premium\", \"Standard\"]."
  }
}

variable "aks_storage_profile" {
  type = object({
    blob_csi_driver = optional(object({
      enabled = optional(bool)
    }))
    disk_csi_driver = optional(object({
      enabled = optional(bool)
    }))
    file_csi_driver = optional(object({
      enabled = optional(bool)
    }))
    snapshot_controller = optional(object({
      enabled = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Storage profile for the container service cluster.

- `blob_csi_driver` - AzureBlob CSI Driver settings for the storage profile.
  - `enabled` - Whether to enable AzureBlob CSI Driver. The default value is false.
- `disk_csi_driver` - AzureDisk CSI Driver settings for the storage profile.
  - `enabled` - Whether to enable AzureDisk CSI Driver. The default value is true.
- `file_csi_driver` - AzureFile CSI Driver settings for the storage profile.
  - `enabled` - Whether to enable AzureFile CSI Driver. The default value is true.
- `snapshot_controller` - Snapshot Controller settings for the storage profile.
  - `enabled` - Whether to enable Snapshot Controller. The default value is true.

DESCRIPTION
}

variable "aks_support_plan" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Different support tiers for AKS managed clusters
DESCRIPTION

  validation {
    condition     = var.aks_support_plan == null || contains(["AKSLongTermSupport", "KubernetesOfficial"], var.aks_support_plan)
    error_message = "aks_support_plan must be one of: [\"AKSLongTermSupport\", \"KubernetesOfficial\"]."
  }
}

variable "aks_tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
(Optional) Tags of the resource.
DESCRIPTION
}

variable "aks_upgrade_settings" {
  type = object({
    override_settings = optional(object({
      force_upgrade = optional(bool)
      until         = optional(string)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Settings for upgrading a cluster.

- `override_settings` - Settings for overrides when upgrading a cluster.
  - `force_upgrade` - Whether to force upgrade the cluster. Note that this option instructs upgrade operation to bypass upgrade protections such as checking for deprecated API usage. Enable this option only with caution.
  - `until` - Until when the overrides are effective. Note that this only matches the start time of an upgrade, and the effectiveness won't change once an upgrade starts even if the `until` expires as upgrade proceeds. This field is not set by default. It must be set for the overrides to take effect.

DESCRIPTION
}

variable "aks_windows_profile" {
  type = object({
    admin_password   = optional(string)
    admin_username   = string
    enable_csi_proxy = optional(bool)
    gmsa_profile = optional(object({
      dns_server       = optional(string)
      enabled          = optional(bool)
      root_domain_name = optional(string)
    }))
    license_type = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Profile for Windows VMs in the managed cluster.

- `admin_password` - Specifies the password of the administrator account. <br><br> **Minimum-length:** 8 characters <br><br> **Max-length:** 123 characters <br><br> **Complexity requirements:** 3 out of 4 conditions below need to be fulfilled <br> Has lower characters <br>Has upper characters <br> Has a digit <br> Has a special character (Regex match [\W_]) <br><br> **Disallowed values:** "abc@123", "P@$$w0rd", "P@ssw0rd", "P@ssword123", "Pa$$word", "pass@word1", "Password!", "Password1", "Password22", "iloveyou!"
- `admin_username` - Specifies the name of the administrator account. <br><br> **Restriction:** Cannot end in "." <br><br> **Disallowed values:** "administrator", "admin", "user", "user1", "test", "user2", "test1", "user3", "admin1", "1", "123", "a", "actuser", "adm", "admin2", "aspnet", "backup", "console", "david", "guest", "john", "owner", "root", "server", "sql", "support", "support_388945a0", "sys", "test2", "test3", "user4", "user5". <br><br> **Minimum-length:** 1 character <br><br> **Max-length:** 20 characters
- `enable_csi_proxy` - Whether to enable CSI proxy. For more details on CSI proxy, see the [CSI proxy GitHub repo](https://github.com/kubernetes-csi/csi-proxy).
- `gmsa_profile` - Windows gMSA Profile in the managed cluster.
  - `dns_server` - Specifies the DNS server for Windows gMSA. <br><br> Set it to empty if you have configured the DNS server in the vnet which is used to create the managed cluster.
  - `enabled` - Whether to enable Windows gMSA. Specifies whether to enable Windows gMSA in the managed cluster.
  - `root_domain_name` - Specifies the root domain name for Windows gMSA. <br><br> Set it to empty if you have configured the DNS server in the vnet which is used to create the managed cluster.
- `license_type` - The license type to use for Windows VMs. See [Azure Hybrid User Benefits](https://azure.microsoft.com/pricing/hybrid-benefit/faq/) for more details.

DESCRIPTION

  validation {
    condition     = var.aks_windows_profile == null || var.aks_windows_profile.license_type == null || contains(["None", "Windows_Server"], var.aks_windows_profile.license_type)
    error_message = "aks_windows_profile.license_type must be one of: [\"None\", \"Windows_Server\"]."
  }
}

variable "aks_windows_profile_password" {
  type        = string
  ephemeral   = true
  default     = null
  description = "(Optional) The Admin Password for Windows VMs. Length must be between 14 and 123 characters."
  sensitive   = true

  validation {
    condition     = var.aks_windows_profile_password == null ? true : length(var.aks_windows_profile_password) >= 14 && length(var.aks_windows_profile_password) <= 123
    error_message = "The Windows profile password must be between 14 and 123 characters long."
  }
}

variable "aks_windows_profile_password_version" {
  type        = string
  default     = null
  description = "(Optional) The version of the Admin Password for Windows VM."

  validation {
    error_message = "Must be specified when `aks_windows_profile_password` is used"
    condition     = var.aks_windows_profile_password != null ? var.aks_windows_profile_password_version != null : true
  }
}

variable "aks_workload_auto_scaler_profile" {
  type = object({
    keda = optional(object({
      enabled = bool
    }))
    vertical_pod_autoscaler = optional(object({
      enabled = bool
    }))
  })
  default     = null
  description = <<DESCRIPTION
Workload Auto-scaler profile for the managed cluster.

- `keda` - KEDA (Kubernetes Event-driven Autoscaling) settings for the workload auto-scaler profile.
  - `enabled` - Whether to enable KEDA.
- `vertical_pod_autoscaler` - VPA (Vertical Pod Autoscaler) settings for the workload auto-scaler profile.
  - `enabled` - Whether to enable VPA. Default value is false.

DESCRIPTION
}

variable "aks_agent_pools" {
  type = map(object({
    availability_zones            = optional(list(string))
    capacity_reservation_group_id = optional(string)
    count_of                      = optional(number)
    creation_data = optional(object({
      source_resource_id = optional(string)
    }))
    enable_auto_scaling       = optional(bool)
    enable_encryption_at_host = optional(bool)
    enable_fips               = optional(bool)
    enable_node_public_ip     = optional(bool)
    enable_ultra_ssd          = optional(bool)
    gateway_profile = optional(object({
      public_ip_prefix_size = optional(number)
    }))
    gpu_instance_profile = optional(string)
    gpu_profile = optional(object({
      driver = optional(string)
    }))
    host_group_id = optional(string)
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_files   = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota             = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      fail_swap_on              = optional(bool)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pids              = optional(number)
      topology_manager_policy   = optional(string)
    }))
    kubelet_disk_type = optional(string)
    linux_os_config = optional(object({
      swap_file_size_mb = optional(number)
      sysctls = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range       = optional(string)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_ipv4_tcpkeepalive_intvl        = optional(number)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(string)
    }))
    local_dns_profile = optional(object({
      kube_dns_overrides = optional(map(object({
        cache_duration_in_seconds       = optional(number)
        forward_destination             = optional(string)
        forward_policy                  = optional(string)
        max_concurrent                  = optional(number)
        protocol                        = optional(string)
        query_logging                   = optional(string)
        serve_stale                     = optional(string)
        serve_stale_duration_in_seconds = optional(number)
      })))
      mode = optional(string)
      vnet_dns_overrides = optional(map(object({
        cache_duration_in_seconds       = optional(number)
        forward_destination             = optional(string)
        forward_policy                  = optional(string)
        max_concurrent                  = optional(number)
        protocol                        = optional(string)
        query_logging                   = optional(string)
        serve_stale                     = optional(string)
        serve_stale_duration_in_seconds = optional(number)
      })))
    }))
    max_count          = optional(number)
    max_pods           = optional(number)
    message_of_the_day = optional(string)
    min_count          = optional(number)
    mode               = optional(string)
    name               = string
    network_profile = optional(object({
      allowed_host_ports = optional(list(object({
        port_end   = optional(number)
        port_start = optional(number)
        protocol   = optional(string)
      })))
      application_security_groups = optional(list(string))
      node_public_ip_tags = optional(list(object({
        ip_tag_type = optional(string)
        tag         = optional(string)
      })))
    }))
    node_labels                  = optional(map(string))
    node_public_ip_prefix_id     = optional(string)
    node_taints                  = optional(list(string))
    orchestrator_version         = optional(string)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string)
    os_sku                       = optional(string)
    os_type                      = optional(string)
    output_data_only             = optional(bool)
    pod_ip_allocation_mode       = optional(string)
    pod_subnet_id                = optional(string)
    pod_subnet_key               = optional(string)
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string)
    scale_set_eviction_policy    = optional(string)
    scale_set_priority           = optional(string)
    security_profile = optional(object({
      enable_secure_boot = optional(bool)
      enable_vtpm        = optional(bool)
      ssh_access         = optional(string)
    }))
    spot_max_price = optional(number)
    tags           = optional(map(string))
    type           = optional(string)
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      max_surge                     = optional(string)
      max_unavailable               = optional(string)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    }))
    virtual_machines_profile = optional(object({
      scale = optional(object({
        manual = optional(list(object({
          count = optional(number)
          size  = optional(string)
        })))
      }))
    }))
    vm_size         = optional(string)
    vnet_subnet_id  = optional(string)
    vnet_subnet_key = optional(string)
    windows_profile = optional(object({
      disable_outbound_nat = optional(bool)
    }))
    workload_runtime = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
Map of instances for the submodule with the following attributes:

**kubelet_config**
Kubelet configurations of agent nodes. See [AKS custom node configuration](https://docs.microsoft.com/azure/aks/custom-node-configuration) for more details.

- `allowed_unsafe_sysctls` - Allowed list of unsafe sysctls or unsafe sysctl patterns (ending in `*`).
- `container_log_max_files` - The maximum number of container log files that can be present for a container. The number must be ≥ 2.
- `container_log_max_size_mb` - The maximum size (e.g. 10Mi) of container log file before it is rotated.
- `cpu_cfs_quota` - If CPU CFS quota enforcement is enabled for containers that specify CPU limits. The default is true.
- `cpu_cfs_quota_period` - The CPU CFS quota period value. The default is '100ms.' Valid values are a sequence of decimal numbers with an optional fraction and a unit suffix. For example: '300ms', '2h45m'. Supported units are 'ns', 'us', 'ms', 's', 'm', and 'h'.
- `cpu_manager_policy` - The CPU Manager policy to use. The default is 'none'. See [Kubernetes CPU management policies](https://kubernetes.io/docs/tasks/administer-cluster/cpu-management-policies/#cpu-management-policies) for more information. Allowed values are 'none' and 'static'.
- `fail_swap_on` - If set to true it will make the Kubelet fail to start if swap is enabled on the node.
- `image_gc_high_threshold` - The percent of disk usage after which image garbage collection is always run. To disable image garbage collection, set to 100. The default is 85%
- `image_gc_low_threshold` - The percent of disk usage before which image garbage collection is never run. This cannot be set higher than imageGcHighThreshold. The default is 80%
- `pod_max_pids` - The maximum number of processes per pod.
- `topology_manager_policy` - The Topology Manager policy to use. For more information see [Kubernetes Topology Manager](https://kubernetes.io/docs/tasks/administer-cluster/topology-manager). The default is 'none'. Allowed values are 'none', 'best-effort', 'restricted', and 'single-numa-node'.

**os_sku**
Specifies the OS SKU used by the agent pool. The default is Ubuntu if OSType is Linux. The default is Windows2019 when Kubernetes <= 1.24 or Windows2022 when Kubernetes >= 1.25 if OSType is Windows.

**upgrade_settings**
Settings for upgrading an agentpool

- `drain_timeout_in_minutes` - The drain timeout for a node. The amount of time (in minutes) to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails. If not specified, the default is 30 minutes.
- `max_surge` - The maximum number or percentage of nodes that are surged during upgrade. This can either be set to an integer (e.g. '5') or a percentage (e.g. '50%'). If a percentage is specified, it is the percentage of the total agent pool size at the time of the upgrade. For percentages, fractional nodes are rounded up. If not specified, the default is 10%. For more information, including best practices, see: https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster
- `max_unavailable` - The maximum number or percentage of nodes that can be simultaneously unavailable during upgrade. This can either be set to an integer (e.g. '1') or a percentage (e.g. '5%'). If a percentage is specified, it is the percentage of the total agent pool size at the time of the upgrade. For percentages, fractional nodes are rounded up. If not specified, the default is 0. For more information, including best practices, see: https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster
- `node_soak_duration_in_minutes` - The soak duration for a node. The amount of time (in minutes) to wait after draining a node and before reimaging it and moving on to next node. If not specified, the default is 0 minutes.
- `undrainable_node_behavior` - Defines the behavior for undrainable nodes during upgrade. The most common cause of undrainable nodes is Pod Disruption Budgets (PDBs), but other issues, such as pod termination grace period is exceeding the remaining per-node drain timeout or pod is still being in a running state, can also cause undrainable nodes.

**virtual_machines_profile**
Specifications on VirtualMachines agent pool.

- `scale` - Specifications on how to scale a VirtualMachines agent pool.
  - `manual` - Specifications on how to scale the VirtualMachines agent pool to a fixed size.

**vm_size**
The size of the agent pool VMs. VM size availability varies by region. If a node contains insufficient compute resources (memory, cpu, etc) pods might fail to run correctly. For more details on restricted VM sizes, see: https://docs.microsoft.com/azure/aks/quotas-skus-regions

**node_public_ip_prefix_id**
The public IP prefix ID which VM nodes should use IPs from. This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPPrefixes/{publicIPPrefixName}

**enable_node_public_ip**
Whether each node is allocated its own public IP. Some scenarios may require nodes in a node pool to receive their own dedicated public IP addresses. A common scenario is for gaming workloads, where a console needs to make a direct connection to a cloud virtual machine to minimize hops. For more information see [assigning a public IP per node](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#assign-a-public-ip-per-node-for-your-node-pools). The default is false.

**node_taints**
The taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.

**orchestrator_version**
The version of Kubernetes specified by the user. Both patch version <major.minor.patch> (e.g. 1.20.13) and <major.minor> (e.g. 1.20) are supported. When <major.minor> is specified, the latest supported GA patch version is chosen automatically. Updating the cluster with the same <major.minor> once it has been created (e.g. 1.14.x -> 1.14) will not trigger an upgrade, even if a newer patch version is available. As a best practice, you should upgrade all node pools in an AKS cluster to the same Kubernetes version. The node pool version must have the same major version as the control plane. The node pool minor version must be within two minor versions of the control plane version. The node pool version cannot be greater than the control plane version. For more information see [upgrading a node pool](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#upgrade-a-node-pool).

**pod_ip_allocation_mode**
Pod IP Allocation Mode. The IP allocation mode for pods in the agent pool. Must be used with podSubnetId. The default is 'DynamicIndividual'.

**scale_down_mode**
Describes how VMs are added to or removed from Agent Pools. See [billing states](https://docs.microsoft.com/azure/virtual-machines/states-billing).

**type**
The type of Agent Pool.

**workload_runtime**
Determines the type of workload a node can run.

**enable_ultra_ssd**
Whether to enable UltraSSD

**security_profile**
The security settings of an agent pool.

- `enable_secure_boot` - Secure Boot is a feature of Trusted Launch which ensures that only signed operating systems and drivers can boot. For more details, see aka.ms/aks/trustedlaunch.  If not specified, the default is false.
- `enable_vtpm` - vTPM is a Trusted Launch feature for configuring a dedicated secure vault for keys and measurements held locally on the node. For more details, see aka.ms/aks/trustedlaunch. If not specified, the default is false.
- `ssh_access` - SSH access method of an agent pool.

**status**
Contains read-only information about the Agent Pool.

**vnet_subnet_id**
The ID of the subnet which agent pool nodes and optionally pods will join on startup. If this is not specified, a VNET and subnet will be generated and used. If no podSubnetID is specified, this applies to nodes and pods, otherwise it applies to just nodes. This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}

**host_group_id**
The fully qualified resource ID of the Dedicated Host Group to provision virtual machines from, used only in creation scenario and not allowed to changed once set. This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/hostGroups/{hostGroupName}. For more information see [Azure dedicated hosts](https://docs.microsoft.com/azure/virtual-machines/dedicated-hosts).

**message_of_the_day**
Message of the day for Linux nodes, base64-encoded. A base64-encoded string which will be written to /etc/motd after decoding. This allows customization of the message of the day for Linux nodes. It must not be specified for Windows nodes. It must be a static string (i.e., will be printed raw and not be executed as a script).

**name**
The name of the resource.
The name must be 1-12 characters long, and must begin with a lowercase letter followed by lowercase letters or numbers.
The name of an agent pool should not be the same as the default agent pool name.
If create_agentpools_before_destroy is enabled, the name must be 1-8 characters long.

**linux_os_config**
OS configurations of Linux agent nodes. See [AKS custom node configuration](https://docs.microsoft.com/azure/aks/custom-node-configuration) for more details.

- `swap_file_size_mb` - The size in MB of a swap file that will be created on each node.
- `sysctls` - Sysctl settings for Linux agent nodes.
  - `fs_aio_max_nr` - Sysctl setting fs.aio-max-nr.
  - `fs_file_max` - Sysctl setting fs.file-max.
  - `fs_inotify_max_user_watches` - Sysctl setting fs.inotify.max_user_watches.
  - `fs_nr_open` - Sysctl setting fs.nr_open.
  - `kernel_threads_max` - Sysctl setting kernel.threads-max.
  - `net_core_netdev_max_backlog` - Sysctl setting net.core.netdev_max_backlog.
  - `net_core_optmem_max` - Sysctl setting net.core.optmem_max.
  - `net_core_rmem_default` - Sysctl setting net.core.rmem_default.
  - `net_core_rmem_max` - Sysctl setting net.core.rmem_max.
  - `net_core_somaxconn` - Sysctl setting net.core.somaxconn.
  - `net_core_wmem_default` - Sysctl setting net.core.wmem_default.
  - `net_core_wmem_max` - Sysctl setting net.core.wmem_max.
  - `net_ipv4_ip_local_port_range` - Sysctl setting net.ipv4.ip_local_port_range.
  - `net_ipv4_neigh_default_gc_thresh1` - Sysctl setting net.ipv4.neigh.default.gc_thresh1.
  - `net_ipv4_neigh_default_gc_thresh2` - Sysctl setting net.ipv4.neigh.default.gc_thresh2.
  - `net_ipv4_neigh_default_gc_thresh3` - Sysctl setting net.ipv4.neigh.default.gc_thresh3.
  - `net_ipv4_tcp_fin_timeout` - Sysctl setting net.ipv4.tcp_fin_timeout.
  - `net_ipv4_tcp_keepalive_probes` - Sysctl setting net.ipv4.tcp_keepalive_probes.
  - `net_ipv4_tcp_keepalive_time` - Sysctl setting net.ipv4.tcp_keepalive_time.
  - `net_ipv4_tcp_max_syn_backlog` - Sysctl setting net.ipv4.tcp_max_syn_backlog.
  - `net_ipv4_tcp_max_tw_buckets` - Sysctl setting net.ipv4.tcp_max_tw_buckets.
  - `net_ipv4_tcp_tw_reuse` - Sysctl setting net.ipv4.tcp_tw_reuse.
  - `net_ipv4_tcpkeepalive_intvl` - Sysctl setting net.ipv4.tcp_keepalive_intvl.
  - `net_netfilter_nf_conntrack_buckets` - Sysctl setting net.netfilter.nf_conntrack_buckets.
  - `net_netfilter_nf_conntrack_max` - Sysctl setting net.netfilter.nf_conntrack_max.
  - `vm_max_map_count` - Sysctl setting vm.max_map_count.
  - `vm_swappiness` - Sysctl setting vm.swappiness.
  - `vm_vfs_cache_pressure` - Sysctl setting vm.vfs_cache_pressure.
- `transparent_huge_page_defrag` - Whether the kernel should make aggressive use of memory compaction to make more hugepages available. Valid values are 'always', 'defer', 'defer+madvise', 'madvise' and 'never'. The default is 'madvise'. For more information see [Transparent Hugepages](https://www.kernel.org/doc/html/latest/admin-guide/mm/transhuge.html#admin-guide-transhuge).
- `transparent_huge_page_enabled` - Whether transparent hugepages are enabled. Valid values are 'always', 'madvise', and 'never'. The default is 'always'. For more information see [Transparent Hugepages](https://www.kernel.org/doc/html/latest/admin-guide/mm/transhuge.html#admin-guide-transhuge).

**min_count**
The minimum number of nodes for auto-scaling

**os_disk_size_gb**
OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified.

**windows_profile**
The Windows agent pool's specific profile.

- `disable_outbound_nat` - Whether to disable OutboundNAT in windows nodes. The default value is false. Outbound NAT can only be disabled if the cluster outboundType is NAT Gateway and the Windows agent pool does not have node public IP enabled.

**count_of**
Number of agents (VMs) to host docker containers. Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools. The default valueis 1.

**enable_auto_scaling**
Whether to enable auto-scaler

**gpu_instance_profile**
GPUInstanceProfile to be used to specify GPU MIG instance profile for supported GPU VM SKU.

**kubelet_disk_type**
Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.

**local_dns_profile**
Configures the per-node local DNS, with VnetDNS and KubeDNS overrides. LocalDNS helps improve performance and reliability of DNS resolution in an AKS cluster. For more details see aka.ms/aks/localdns.

- `kube_dns_overrides` - LocalDNSOverrides is a map of zone names for Vnet and Kube DNS overrides.
- `mode` - Mode of enablement for localDNS.
- `vnet_dns_overrides` - LocalDNSOverrides is a map of zone names for Vnet and Kube DNS overrides.

**max_count**
The maximum number of nodes for auto-scaling

**max_pods**
The maximum number of pods that can run on a node.

**os_type**
The operating system type. The default is Linux.

**capacity_reservation_group_id**
The fully qualified resource ID of the Capacity Reservation Group to provide virtual machines from a reserved group of Virtual Machines. This is of the form: '/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.Compute/capacityreservationgroups/{capacityReservationGroupName}' Customers use it to create an agentpool with a specified CRG. For more information see [Capacity Reservation](https://learn.microsoft.com/en-us/azure/virtual-machines/capacity-reservation-overview)

**creation_data**
Data used when creating a target resource from a source resource.

- `source_resource_id` - This is the ARM ID of the source object to be used to create the target object.


**gateway_profile**
Profile of the managed cluster gateway agent pool.

- `public_ip_prefix_size` - The Gateway agent pool associates one public IPPrefix for each static egress gateway to provide public egress. The size of Public IPPrefix should be selected by the user. Each node in the agent pool is assigned with one IP from the IPPrefix. The IPPrefix size thus serves as a cap on the size of the Gateway agent pool. Due to Azure public IPPrefix size limitation, the valid value range is [28, 31] (/31 = 2 nodes/IPs, /30 = 4 nodes/IPs, /29 = 8 nodes/IPs, /28 = 16 nodes/IPs). The default value is 31.

**node_labels**
The node labels to be persisted across all nodes in agent pool.

**os_disk_type**
The OS disk type to be used for machines in the agent pool. The default is 'Ephemeral' if the VM supports it and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to 'Managed'. May not be changed after creation. For more information see [Ephemeral OS](https://docs.microsoft.com/azure/aks/cluster-configuration#ephemeral-os).

**proximity_placement_group_id**
The ID for Proximity Placement Group.

**scale_set_eviction_policy**
The Virtual Machine Scale Set eviction policy. The eviction policy specifies what to do with the VM when it is evicted. The default is Delete. For more information about eviction see [spot VMs](https://docs.microsoft.com/azure/virtual-machines/spot-vms)

**tags**
The tags to be persisted on the agent pool virtual machine scale set.

**output_data_only**
Whether to disable creation of the resource and only output a the resource's body properties.

**enable_encryption_at_host**
Whether to enable host based OS and data drive encryption. This is only supported on certain VM sizes and in certain Azure regions. For more information, see: https://docs.microsoft.com/azure/aks/enable-host-encryption

**gpu_profile**
GPU settings for the Agent Pool.

- `driver` - Whether to install GPU drivers. When it's not specified, default is Install.

**mode**
The mode of an agent pool. A cluster must have at least one 'System' Agent Pool at all times. For additional information on agent pool restrictions and best practices, see: https://docs.microsoft.com/azure/aks/use-system-pools

**network_profile**
Network settings of an agent pool.

- `allowed_host_ports` - The port ranges that are allowed to access. The specified ranges are allowed to overlap.
- `application_security_groups` - The IDs of the application security groups which agent pool will associate when created.
- `node_public_ip_tags` - The list of tags associated with the node public IP address.

**pod_subnet_id**
The ID of the subnet which pods will join when launched. If omitted, pod IPs are statically assigned on the node subnet (see vnetSubnetID for more details). This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}

**scale_set_priority**
The Virtual Machine Scale Set priority.

**spot_max_price**
The max price (in US Dollars) you are willing to pay for spot instances. Possible values are any decimal value greater than zero or -1 which indicates default price to be up-to on-demand. Possible values are any decimal value greater than zero or -1 which indicates the willingness to pay any on-demand price. For more details on spot pricing, see [spot VMs pricing](https://docs.microsoft.com/azure/virtual-machines/spot-vms#pricing)

**availability_zones**
The list of Availability zones to use for nodes. This can only be specified if the AgentPoolType property is 'VirtualMachineScaleSets'.

**enable_fips**
Whether to use a FIPS-enabled OS. See [Add a FIPS-enabled node pool](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#add-a-fips-enabled-node-pool-preview) for more details.
DESCRIPTION

  validation {
    error_message = "The name must not be the same as the default agent pool name."
    condition     = alltrue([for k, v in var.aks_agent_pools : v.name != var.aks_default_agent_pool.name])
  }
}