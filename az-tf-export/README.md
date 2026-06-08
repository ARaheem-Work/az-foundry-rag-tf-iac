# az-tf-export

Command notes for exporting existing Azure resources into Terraform-compatible HCL using `aztfexport`.

## Folder Contents

- `az-tf-export-commands`: Saved export command examples

## Prerequisites

- Azure CLI installed and signed in
- Azure Export for Terraform (`aztfexport`) installed and available in PATH
- Access to the target subscription/resource group/resources

## Recorded Commands

The `az-tf-export-commands` file currently contains:

1. Resource group export
2. Resource-by-list export from a text file

## Example Usage

Run from any terminal where `aztfexport` is available:

```powershell
aztfexport resource-group -provider-name=azurerm --hcl-only --non-interactive <resource-group-name>
```

Export specific resources from a list file:

```powershell
aztfexport resource -provider-name=azurerm --hcl-only --non-interactive @<path-to-resources-list.txt>
```

## Suggested Export Workflow

1. Authenticate and select subscription:

```powershell
az login --tenant <Your-Tenant-ID> --use-device-code
az account set --subscription <your-subscription-id-or-name>
```

2. Run export command for your scope (resource group or specific resources).
3. Review generated HCL files.
4. Move validated configuration into your infrastructure folder (for example `az-tf-infra`) and refactor names/variables as needed.

## Notes

- `--hcl-only` skips state import and focuses on generating Terraform configuration files.
- `--non-interactive` is useful for automation and reproducible runs.
- Keep resource list files under source control when using targeted exports.
