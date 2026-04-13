# IaC-SimpleTimeService

Terraform deployment for AKS infrastructure with networking, container registry, and monitoring.

## 🏗️ Infrastructure

- **Networking**: VNet with public/private subnets
- **Compute**: AKS cluster in private subnets
- **Ingress**: Application Gateway in public subnet
- **Registry**: Azure Container Registry (ACR)
- **Security**: Key Vault, Managed Identities
- **Monitoring**: Azure Monitor

## 📋 Prerequisites

- **Terraform** >= 1.5.0 — [Install](https://www.terraform.io/downloads)
- **Azure CLI** — [Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Azure subscription** with Contributor role

## 🚀 Deploy

```bash
# 1. Authenticate
az login
az account set --subscription <your-subscription-id>

# 2. Configure
# Edit terraform.tfvars with your subscription ID
subscription_id = "<your-azure-subscription-id>"

# Get your subscription ID:
az account show --query id --output tsv

# 3. Deploy
terraform init
terraform plan
terraform apply
```

⏱️ **Deployment time**: 15-30 minutes (AKS cluster creation is the longest)

## 📁 File Structure

```
IaC-SimpleTimeService/
├── main*.tf              # Resource definitions (network, AKS, ACR, etc.)
├── variables*.tf         # Variable definitions
├── data.tf              # Data sources
├── locals.tf            # Local variables
├── outputs.tf           # Output values
├── terraform.tf         # Terraform version & provider config
├── backend.tf           # State backend
├── backend.json         # Backend config
├── terraform.tfvars     # Your configuration (edit this)
└── terraform.*auto.tfvars  # Default values
```

## ⚠️ Important Notes

- **Credentials**: Never commit credentials to Git. Use `az login` for auth.
- **State File**: Remove `.tfstate*` files if pushing to Git
- **Cleanup**: Run `terraform destroy` to avoid charges
- **Cost**: AKS and other resources incur Azure costs

## 🔄 (Optional) CI/CD with GitHub Actions

To automate deployments, set up Azure federated credentials and GitHub secrets. See `.github/workflows/` for example workflows.

```hcl
subscription_id = "<your-azure-subscription-id>"
```

Find your subscription ID:
```bash
az account show --query id --output tsv
```

### Step 4: Initialize Terraform

```bash
terraform init
```

This:
- Downloads required providers
- Initializes the backend
- Creates `.terraform` directory

### Step 5: Validate Configuration

```bash
terraform validate
```

### Step 6: Review Deployment Plan

```bash
terraform plan -out=tfplan
```

This shows all resources that will be created.

### Step 7: Apply Infrastructure

```bash
terraform apply tfplan
```

⏱️ Deployment takes 15-30 minutes (AKS cluster creation is the longest step).

## 📁 Structure

```
IaC-SimpleTimeService/
├── # Core Terraform Configuration
├── main.tf                          # Primary resource definitions
├── terraform.tf                     # Terraform version requirements
├── providers.tf                     # Azure provider configuration
├── backend.tf                       # State file backend
├── backend.json                     # Backend configuration
│
├── # Variable Definitions
├── variables.tf                     # Root variables
├── variables.network.tf             # Network/VNet variables
├── variables.aks.tf                 # AKS cluster variables
├── variables.acr.tf                 # Container Registry variables
├── variables.keyvault.tf            # Key Vault variables
├── variables.monitor.tf             # Monitoring variables
├── variables.appgw.tf               # Application Gateway variables
│
├── # Data Sources & Locals
├── data.tf                          # Data sources
├── locals.tf                        # Local variable computation
│
├── # Resource Modules
├── main.network.tf                  # VNet, subnets, NSGs
├── main.aks.tf                      # AKS cluster
├── main.acr.tf                      # Container Registry
├── main.keyvault.tf                 # Key Vault
├── main.monitor.tf                  # Monitoring
├── main.appgw.tf                    # Application Gateway
├── main.identity.tf                 # Managed Identities
│
├── # Configuration Files
├── terraform.tfvars                 # Manual configuration overrides
├── terraform.network.auto.tfvars    # Network defaults
├── terraform.aks.auto.tfvars        # AKS defaults
├── terraform.acr.auto.tfvars        # ACR defaults
├── terraform.keyvault.auto.tfvars   # Key Vault defaults
├── terraform.monitor.auto.tfvars    # Monitoring defaults
├── terraform.appgw.auto.tfvars      # App Gateway defaults
│
├── # Outputs & CI/CD
├── outputs.tf                       # Output values
├── .github/workflows/               # CI/CD pipelines
│   ├── tf-test.yaml                 # Validation & security scan
│   ├── tf-plan.yaml                 # Plan preview
│   └── tf-apply.yaml                # Automated apply
│
├── .gitignore                       # Git exclusions
├── .terraform.lock.hcl              # Dependency lock
└── README.md                        # Documentation
```

## � CI/CD Setup (GitHub Actions)

### Create Azure Managed Identities

```bash
# For IaC operations
az identity create \
  --resource-group <rg-name> \
  --name uai-az-avm-prod-eastus-iac

# Get the identity ID
IDENTITY_ID=$(az identity show \
  --resource-group <rg-name> \
  --name uai-az-avm-prod-eastus-iac \
  --query id -o tsv)

# Assign Contributor role
az role assignment create \
  --role Contributor \
  --assignee-object-id $(az identity show \
    --resource-group <rg-name> \
    --name uai-az-avm-prod-eastus-iac \
    --query principalId -o tsv) \
  --scope /subscriptions/<subscription-id>
```

### Create Federated Credential

```bash
az identity federated-credential create \
  --identity-name uai-az-avm-prod-eastus-iac \
  --resource-group <rg-name> \
  --issuer https://token.actions.githubusercontent.com \
  --subject "repo:Phoenix486/IaC-SimpleTimeService:environment:Production" \
  --audience api://AzureADTokenExchange
```

### Add GitHub Secrets

In repository settings, add these secrets:
- `AZURE_CLIENT_ID`: Client ID of the managed identity
- `AZURE_TENANT_ID`: Your Azure Tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Subscription ID

Get values with:
```bash
az identity show --resource-group <rg-name> --name uai-az-avm-prod-eastus-iac --query clientId -o tsv
az account show --query tenantId -o tsv
az account show --query id -o tsv
```

## �🔄 CI/CD Pipeline

**Automated GitHub Actions Workflows:**

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **tf-test.yaml** | PR | Validation, formatting, KICS security scan |
| **tf-plan.yaml** | PR | Terraform plan preview |
| **tf-apply.yaml** | Merge to main | Automated infrastructure deployment |

## 🧹 Cleanup

```bash
terraform destroy
```

## 📚 Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)

## ⚠️ Known Issues

### 1. KICS Security Scan Stuck
The `tf-test.yaml` GitHub Actions workflow may hang during KICS scanning. This is a known issue with the KICS tool on large Terraform projects. 

**Workaround**: Manually skip KICS in the workflow or increase the timeout threshold.

### 2. API Server Subnet Delegation Changes Fail
Terraform plan shows NSG rule changes for API server subnet delegation, but `terraform apply` fails because Azure doesn't allow removing these delegations after creation.

**Workaround**: These changes are safe to ignore. They exist by design and cannot be modified or removed from Terraform. To avoid the error, manually set `lifecycle { ignore_changes = [delegation] }` on the subnet resource or apply with `-auto-approve` after reviewing the changes.

### 3. AGIC Ingress UAMI Role Assignments Not in Terraform
The Application Gateway Ingress Controller (AGIC) is deployed as an AKS addon, which auto-creates a managed identity. The role assignments for this identity must currently be added manually to Azure via the portal or Azure CLI, as they are not managed by this Terraform configuration.

**Workaround**: After deployment, manually assign these roles to the auto-created AGIC identity:
```bash
# Get AGIC identity object ID
AGIC_PRINCIPAL_ID=$(az identity show \
  --resource-group <node-resource-group> \
  --name <agic-identity-name> \
  --query principalId -o tsv)

# Assign Contributor on Application Gateway
az role assignment create \
  --role Contributor \
  --assignee-object-id $AGIC_PRINCIPAL_ID \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/applicationGateways/<agw-name>

# Assign Reader on resource group
az role assignment create \
  --role Reader \
  --assignee-object-id $AGIC_PRINCIPAL_ID \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>
```

**Future Enhancement**: Move AGIC to manual deployment via Helm and integrate with AKS managed identity to avoid this manual step.

### 4. Application Gateway SSL Certificate Removed on Re-apply
SSL certificates added manually to the Application Gateway are deleted during subsequent `terraform apply` runs because they are not managed in the Terraform configuration.

**Workaround**: Add SSL certificates to `terraform.appgw.auto.tfvars` in the `agw_ssl_profile` section to manage them via Terraform, or use Azure Key Vault integration to automate certificate rotation.

**Manual Process**: To add certificates temporarily:
```bash
az network application-gateway ssl-cert create \
  --name <cert-name> \
  --gateway-name <agw-name> \
  --resource-group <rg-name> \
  --cert-file <path-to-cert> \
  --cert-password <password>
```

---

**Last Updated**: April 2026