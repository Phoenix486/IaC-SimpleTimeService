subscription_id  = "66e1fc04-0db9-437d-9833-2a35f1098fa2"
location         = "eastus"
brand            = "avm"
application      = "sts"
environment      = "prod"
enable_telemetry = false

user_assigned_managed_identities = {
  "aks" = {
    name = "aks"
  }
  "agw" = {
    name = "agw"
  }
}