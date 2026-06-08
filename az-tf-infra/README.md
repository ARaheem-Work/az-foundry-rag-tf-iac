# az-tf-infra

Terraform configuration for provisioning Azure infrastructure for a RAG-style workload using Azure AI Foundry, App Service, networking, and supporting data services.

## Folder Contents

- `main.tf`: Core Azure resources (resource group, network, Foundry account/project/deployment, web apps, storage, Cosmos DB, Speech, Search)
- `variables.tf`: Input variables with validation
- `terraform.tfvars`: Local variable values for this environment
- `versions.tf`: Terraform and provider requirements
- `outputs.tf`: Output definitions (currently empty)

## Prerequisites

- Terraform 1.6+ (recommended)
- Azure CLI installed and signed in
- Access to an Azure subscription with permission to create:
  - Resource groups
  - Networking resources
  - App Service resources
  - Cognitive Services / Azure AI resources
  - Storage, Cosmos DB, Search

## Quick Start

1. Open a terminal in this folder.
2. Authenticate to Azure:

```powershell
az login
az account set --subscription <your-subscription-id-or-name>
```

3. Initialize Terraform:

```powershell
terraform init
```

4. Validate and preview changes:

```powershell
terraform validate
terraform plan -out tfplan
```

5. Deploy:

```powershell
terraform apply tfplan
```

## Variable Model

This project uses CAF-style naming input variables:

- `workload_name` (example: `rag`)
- `environment` (allowed: `dev`, `tst`, `uat`, `prd`, `sbx`)
- `location_short` (example: `wus3`)
- `instance` (3-digit string, example: `001`)

Edit values in `terraform.tfvars` for your target environment.

## Resource Naming

Resource names are derived from:

- `caf_base = <workload_name>-<environment>-<location_short>-<instance>`

Most resource names are generated from that base to keep names consistent across environments.

## Typical Workflow

```powershell
terraform fmt
terraform validate
terraform plan
terraform apply
```

To tear down:

```powershell
terraform destroy
```

## Notes

- Region is currently set in `main.tf` for the resource group (`westus3`).
- `outputs.tf` is empty and can be extended with endpoint, name, or ID outputs as needed.
- State is local unless you configure a remote backend.
