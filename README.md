# Orders API — Desafio DevOps

Uma implementação de infraestrutura de nível de produção para uma Web API em .NET 8, com foco em Azure, Kubernetes (AKS) e práticas modernas de SRE.

## 🏗️ Visão Geral da Arquitetura

- **App:** ASP.NET Core 8 Web API (`orders-api`).
- **Infraestrutura:** Provisionada via Terraform (Azure).
- **Orquestração:** Azure Kubernetes Service (AKS).
- **Registro de Containers:** Azure Container Registry (ACR).
- **Banco de Dados:** Azure Database for PostgreSQL Flexible Server.
- **Storage:** Azure Blob Storage para anexos.
- **Segredos:** Azure Key Vault (Integrado via Variable Groups do Azure DevOps).

## 🚀 Como Começar

### Pré-requisitos

- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)
- [Terraform](https://www.terraform.io/) (>= 1.5.0)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- `make` (opcional, para comandos utilitários)

### Desenvolvimento Local

O projeto inclui um `docker-compose.yml` que simula todas as dependências do Azure localmente usando **Azurite** (para Blob Storage) e **PostgreSQL**.

```bash
# Iniciar o ambiente local (API + DB + Mock Storage)
make dev-up

# Ver logs
make dev-logs

# Parar o ambiente
make dev-down
```

A API estará disponível em `http://localhost:8080/weatherforecast`.

## 🛠️ Infraestrutura (Terraform)

O código de infraestrutura está localizado no diretório `.terraform/` (Restrição de Layout do Projeto).

### Plano & Validação
Para validar as mudanças de infraestrutura sem aplicá-las:

```bash
# Inicializar o Terraform
make tf-init

# Validar a sintaxe
make tf-validate

# Gerar um plano de execução
# Nota: Requer um arquivo local.tfvars com a postgres_admin_password
make tf-plan
```

## 📦 Pipeline CI/CD

O projeto utiliza o **Azure Pipelines** (`azure-pipelines.yaml`) com um fluxo de alta eficiência:

1.  **Build & Push:** Estágio único que constrói a imagem Docker e envia para o ACR em um único fluxo, evitando exportações lentas de tarball.
2.  **Deploy:** Utiliza `kustomize` para atualizar as tags de imagem e aplica os manifestos no cluster AKS.

### Tagging de Imagem
As imagens são tageadas com o **Commit SHA** para total rastreabilidade e deployments imutáveis.

## 🛡️ Práticas de SRE Implementadas

- **Builds Docker Multi-stage:** Otimizado para imagens de runtime pequenas e seguras (sem o SDK em produção).
- **Execução Não-Root:** A aplicação roda como o usuário `app` dentro do container.
- **Restrições de Recursos:** Manifestos K8s incluem `requests` e `limits` explícitos de CPU/Memória.
- **Health Probes:** Configuração completa de probes `liveness`, `readiness` e `startup` para K8s.
- **Segurança de Segredos:** Segredos do Terraform foram externalizados e marcados como `sensitive`.

## 🗺️ Roadmap Futuro

- [ ] **Workload Identity:** Migrar de strings de conexão para Azure Managed Identities no AKS.
- [ ] **Secrets Store CSI:** Montar segredos do Key Vault diretamente como volumes no K8s.
- [ ] **Escaneamento de Segurança:** Integrar Trivy e Checkov no pipeline.
- [ ] **Deployment Blue/Green:** Implementar estratégias de canary release no Azure DevOps.
