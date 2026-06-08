# az-foundry-rag-tf-iac

## az-tf-infra

Terraform infrastructure configuration for provisioning Azure resources used by the solution.

- Folder: [az-tf-infra](az-tf-infra)
- Detailed guide: [az-tf-infra/README.md](az-tf-infra/README.md)
- Includes:
  - Core Terraform files (`main.tf`, `variables.tf`, `terraform.tfvars`, `versions.tf`)
  - Azure networking, App Service, Azure AI Foundry, Storage, Cosmos DB, Speech, and Search resources

## az-tf-export

Command workspace for exporting existing Azure resources into Terraform-compatible HCL.

- Folder: [az-tf-export](az-tf-export)
- Detailed guide: [az-tf-export/README.md](az-tf-export/README.md)
- Includes:
  - Saved `aztfexport` command examples in `az-tf-export-commands`
  - Resource-group and targeted resource export patterns
