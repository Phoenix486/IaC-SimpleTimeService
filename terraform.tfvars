subscription_id  = "a7966b6a-d07a-49c2-849d-ff6d09986924"
location         = "eastus"
brand            = "az"
application      = "avm"
environment      = "test"
enable_telemetry = false

user_assigned_managed_identities = {
  "aks" = {
    name = "aks"
  }
  "agw" = {
    name = "agw"
  }
}