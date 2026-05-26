# Terraform Documentation

This document describes the Infrastructure as Code (IaC) configuration for the Orders API project.

## 📁 Directory Structure
Due to project constraints, Terraform source files are located in the `.terraform/` directory.

- `main.tf`: Provider configuration, backend settings, and core resources (Resource Group).
- `variables.tf`: Input variables and environment configurations.
- `aks.tf`: Azure Kubernetes Service (AKS) cluster definition.
- `acr.tf`: Azure Container Registry (ACR) for image hosting.
- `postgres.tf`: Azure Database for PostgreSQL Flexible Server.
- `key-vault.tf`: Key Vault for secret management.
- `storage-account.tf`: Storage account for application attachments.
- `network.tf`: Virtual Network (VNet) and Subnet definitions.

## ⚙️ Configuration Details

### 1. Resource Group
All resources are grouped under a single Resource Group defined by the `resource_group_name` variable.

### 2. Networking
- **VNet:** A dedicated Virtual Network is created to host the AKS cluster and the PostgreSQL flexible server.
- **Subnets:**
  - `aks-subnet`: Dedicated to the AKS node pools.
  - `db-subnet`: Delegated to the PostgreSQL flexible server for private connectivity.

### 3. Compute (AKS)
The AKS cluster is configured with:
- **Node Pool:** System node pool for core services.
- **Add-ons:** Managed identity and integration with ACR for image pulling.

### 4. Database (PostgreSQL)
A Flexible Server is used with:
- **Private Access:** Connectivity is restricted to the internal VNet via a delegated subnet.
- **Authentication:** Managed via admin credentials (externalized as sensitive variables).

### 5. Secret Management
Azure Key Vault is provisioned to store:
- Database connection strings.
- Storage account access keys.
Access policies are configured for the deploying user/service principal.

## 📋 Variables

| Name | Type | Description | Default |
| :--- | :--- | :--- | :--- |
| `location` | `string` | Azure region for resources. | `West Europe` |
| `resource_group_name` | `string` | Name of the Resource Group. | `rg-atlas-prod` |
| `postgres_admin_login` | `string` | Admin username for PostgreSQL. | `psqladmin` |
| `postgres_admin_password` | `string` | Admin password (Sensitive). | N/A |

## 🚀 Usage

### Local Validation
1. Create a `local.tfvars` file with the required sensitive values.
2. Run `make tf-init`.
3. Run `make tf-plan` to see the proposed changes.

### State Management
The project is configured to use the `azurerm` backend. Ensure you provide the backend configuration (Storage Account, Container, Key) during `terraform init` or via a `.conf` file.
