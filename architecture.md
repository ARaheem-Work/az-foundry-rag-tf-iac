# Azure Architecture (ASCII)

Derived from resources in az-tf-infra/main.tf.

## 1) Logical Architecture (easy view)

```text
Internet Users
	  |
	  v
+-----------------------------+
| Frontend App Service        |
| appfe-<caf_base>            |
+--------------+--------------+
					|
					v
+-----------------------------+
| Backend App Service         |
| appbe-<caf_base>            |
+--+-----------+------+-------+
	|           |      | 
	|           |      +--------------------------+
	|           |                                 |
	v           v                                 v
+-------------------------+     +-----------------------------+
| Azure AI Services       |     | Azure AI Search             |
| Foundry Account         |     | srch-<caf_base>             |
| ais-<caf_base>          |     +-----------------------------+
|  - Foundry Project      |
|  - GPT-5.2 Deployment   |
+-------------------------+

	+----------------------------------+------------------------+
	|                                  |                        |
	v                                  v                        v
+-------------------------+  +-------------------------+  +-------------------------+
| Storage Account         |  | Cosmos DB Account       |  | Speech Service          |
| st<caf_base>            |  | cosmos-<caf_base>       |  | speech-<caf_base>       |
| (public access: off)    |  | (public access: off)    |  | (AIServices Speech)     |
+-------------------------+  +-------------------------+  +-------------------------+
```

## 2) Network and Security Layout

```text
+----------------------------------------------------------------------------------+
| Resource Group: rg-<caf_base>                                                    |
|                                                                                  |
|  +-------------------------- Virtual Network: vnet-<caf_base> ----------------+  |
|  |                                                                            |  |
|  |  +---------------------------+    +-------------------------------------+  |  |
|  |  | Integration Subnet        |    | Private Endpoints Subnet            |  |  |
|  |  | snet-int-<caf_base>       |    | snet-pep-<caf_base>                 |  |  |
|  |  +-------------+-------------+    +-----------+-----------+-------------+  |  |
|  |                |                              |           |                |  |
|  +----------------|------------------------------|-----------|----------------+  |
|                   |                              |           |                   |
|      Frontend App VNet Integration               |           |                   |
|                                                  |           |                   |
|                                     +------------v--+   +---v---------------+    |
|                                     | PE: Backend   |   | PE: Cosmos DB     |    |
|                                     | App Service   |   | SQL endpoint      |    |
|                                     +---------------+   +-------------------+    |
|                                                  |
|                                           +------v----------------+
|                                           | PE: Storage Account   |
|                                           | Blob endpoint         |
|                                           +-----------------------+
|                                                                                  |
|  Private DNS Zones linked to VNet:                                               |
|  - privatelink.azurewebsites.net                                                 |
|  - privatelink.documents.azure.com                                               |
+----------------------------------------------------------------------------------+
```

## 3) Request Flow

```text
1. User calls Frontend App Service.
2. Frontend calls Backend App Service.
3. Backend accesses AI + data services:
	- Azure AI Foundry (project + GPT deployment)
	- Azure AI Search
	- Storage Account
	- Cosmos DB
	- Speech Service
4. Private endpoints + private DNS are used for private network paths where configured.
```
