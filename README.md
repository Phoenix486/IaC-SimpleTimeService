# IaC-SimpleTimeService

Infrastructure-as-Code deployment for SimpleTimeService using Terraform and Azure.

> 📌 **Note**: Application deployment is handled via GitOps. This repository focuses on infrastructure provisioning only.

## 🎯 Purpose

Deploy AKS infrastructure with:
- VNet with public/private subnets
- AKS cluster in private subnet
- Application Gateway in public subnet
- ACR, Key Vault, Azure Monitor

## 📋 Prerequisites

- **Terraform** (>= 1.5.0) - [Install](https://www.terraform.io/downloads)
- **Azure CLI** - [Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Git** - [Install](https://git-scm.com/downloads)
- Active Azure subscription with Contributor role

## 🚀 Local Deployment

### Step 1: Prerequisites Check

```bash
# Verify Terraform installation
terraform version

# Verify Azure CLI installation
az version

# Authenticate with Azure
az login
az account set --subscription <your-subscription-id>

# Verify credentials
az account show
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/YOUR-ORG/IaC-SimpleTimeService.git
cd IaC-SimpleTimeService
```

### Step 3: Configure Azure Subscription

Edit `terraform.tfvars` and update the subscription ID:

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

---

**Last Updated**: April 2026