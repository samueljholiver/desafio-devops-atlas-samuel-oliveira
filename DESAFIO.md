# Desafio Técnico — DevOps

## Contexto

Você foi contratado(a) como DevOps em uma squad que precisa colocar uma aplicação web nova
em produção no Azure. A squad já tem o código pronto (uma API em ASP.NET Core), e precisa
que você:

1. Provisione a infraestrutura no Azure usando **Terraform**.
2. Crie um `azure-pipelines.yml` para **CI/CD no Azure DevOps**, junto com `Dockerfile`,
   `docker-compose.yaml` e os manifests Kubernetes (`Deployment`/`Service`) da aplicação.

O desafio é **ao vivo, com compartilhamento de tela**, dividido em duas etapas. Você pode
parar para pensar em voz alta, perguntar, mudar de ideia — queremos entender seu
raciocínio, não só o resultado final.

> **Tempo total:** 1 hora (30 min para Etapa 1 + 30 min para Etapa 2). Com esse tempo é
> **impossível** entregar tudo bem feito — e isso é proposital. Queremos ver suas
> escolhas: o que você prioriza, o que faria diferente em produção, e o que
> delega para a IA na Etapa 2. **Pare em qualquer momento para explicar trade-offs** — isso
> conta mais do que terminar.

> **Não vai subir nada de verdade.** Não tem Azure real, não tem AKS, não tem ACR. Você
> **não precisa** rodar `terraform apply`, fazer `docker push`, nem deployar manifests. O
> entregável é **código** — TF, Dockerfile, compose, manifests, pipeline YAML — coerente
> e bem estruturado. `terraform validate` e `docker build` podem ser usados localmente se
> quiser, mas nada precisa de credencial Azure.

---

## Etapa 0 — Antes da call (faça nos 30 min que antecedem a entrevista)

Você recebe este desafio **30 minutos antes** da entrevista técnica. Use esse tempo para
preparar o ambiente — **não comece a resolver as etapas 1 e 2 antes da call**.

1. **Crie um repositório público** seu (GitHub, GitLab, etc.) — pode se chamar
   `desafio-devops-atlas-seunome`, ou o que preferir.
2. **Copie o conteúdo deste repositório** para dentro do seu (a pasta `orders-api/`,
   este `DESAFIO.md`, e o `.gitignore` da raiz). Faça um commit inicial do tipo
   `chore: bootstrap challenge baseline`.
3. **Faça push** desse commit inicial. A partir daí, todo o trabalho da call será feito
   nesse seu repositório, e ao final você dará push novamente para que possamos revisar
   nos dias seguintes.
4. **Leia o desafio inteiro** para chegar na call com perguntas, não com surpresas.
5. **Confirme as ferramentas** instaladas — ver "Setup esperado" no fim deste arquivo.
6. (Opcional) Deixe sua IA preferida aberta e logada.

> **Não pré-codifique** as etapas 1 ou 2. Queremos ver você raciocinar e digitar ao vivo.
> Compartilhe o link do seu repositório com a equipe da call assim que terminar este
> Etapa 0.

Ao final da call, faça **um último `git push`** com tudo que produziu. Esse será o
artefato analisado depois.

---

## Aplicação de exemplo (contexto compartilhado)

- **Nome:** `orders-api`
- **Código:** já está pronto na pasta [`orders-api/`](./orders-api), gerada a partir do
  template oficial `dotnet new webapi` (open source MIT, `dotnet/sdk`). Não precisa
  alterar o C#.
- **Stack:** ASP.NET Core 8 (Web API).
- **Porta:** `8080`.
- **Healthcheck:** `/health`.
- **Endpoint de exemplo:** `/weatherforecast`.
- **Dependências externas:**
  - PostgreSQL (Azure Database for PostgreSQL Flexible Server)
  - Um Storage Account (blob) para upload de anexos.
  - Variáveis sensíveis (connection string do banco, chave da storage) que **não podem**
    ficar hardcoded nem no repositório.
- **Ambientes previstos:** `dev` e `prod` (mesmo código TF, valores diferentes).
- **Deploy alvo:** AKS (Azure Kubernetes Service), imagem hospedada em ACR.

> Você não precisa que a aplicação funcione de ponta a ponta.

---

## Etapa 1 — Infraestrutura no Azure com Terraform (hands-on)

**Duração:** 30 minutos
**Uso de IA:** permitido **apenas para tirar dúvidas pontuais** (ex.: "qual o nome do
argumento X no resource Y?", "qual a diferença entre `azurerm_kubernetes_cluster` e
`azurerm_kubernetes_cluster_node_pool`?"). **Não é permitido pedir para a IA gerar código,
módulos ou arquivos prontos.** Você deve digitar e estruturar você mesmo(a).

### Recursos a modelar no Terraform

Mínimo esperado (não precisa aplicar — só ter o código):

- [ ] Resource Group
- [ ] Virtual Network + ao menos uma subnet para o AKS
- [ ] AKS cluster
- [ ] Azure Container Registry (ACR) com integração ao AKS (pull autorizado)
- [ ] Key Vault para guardar segredos da aplicação
- [ ] Storage Account
- [ ] Azure Database for PostgreSQL Flexible Server

> **Importante:** o objetivo é o **código**, não recursos provisionados. Foque em
> **estrutura, código que passe `terraform validate`, e explicar suas escolhas em voz
> alta**. Vamos fazer perguntas enquanto você codifica.

---

## Etapa 2 — CI/CD, containerização e manifests Kubernetes (com IA liberada)

**Duração:** 30 minutos
**Uso de IA:** **liberado integralmente** — pode usar Claude, Copilot, ChatGPT, Cursor,
o que preferir, inclusive para gerar arquivos completos.

### Entregáveis

1. **`Dockerfile`** para a `orders-api`
   - Multi-stage usando `mcr.microsoft.com/dotnet/sdk:8.0` (build) +
     `mcr.microsoft.com/dotnet/aspnet:8.0` (runtime). Pode usar a variante `-alpine` ou
     `chiseled` se quiser imagem menor.
   - Usuário não-root (em .NET 8 a imagem `aspnet` já roda como `app`, não desfaça isso).
   - Healthcheck apontando para `/health`.
   - `dotnet publish` em modo `Release`, sem o SDK na imagem final.

2. **`docker-compose.yaml`** para rodar localmente
   - API + Postgres + (opcional) um mock de storage
   - Variáveis via `.env`

3. **Manifests Kubernetes** (`k8s/` ou similar)
   - `Deployment` da API (replicas, resources requests/limits, probes liveness/readiness,
     pull da imagem do ACR)
   - `Service` (ClusterIP ou LoadBalancer — justifique)
   - `ConfigMap` e/ou integração com Key Vault para os segredos
   - (Bônus) `HorizontalPodAutoscaler`

4. **Pipeline Azure DevOps** (`azure-pipelines.yaml`)
   - Stages claros: `build` → `push` (ACR) → `deploy` (AKS)
   - Build da imagem com tag baseada em commit/SHA
   - Push autenticado no ACR
   - Deploy no AKS (pode ser `kubectl apply`, `helm`, `kustomize` — sua escolha,
     justifique)
   - Trigger só em `main` (ou política que você defender)
   - Variáveis sensíveis vindas de **variable groups** ligados ao Key Vault, não
     hardcoded no YAML

---

## Setup esperado (avisar com antecedência)

Nada precisa estar conectado a Azure real. O que ajuda ter na máquina:

- `terraform` instalado (para `fmt`/`validate` localmente, se quiser)
- `docker` (opcional — só se quiser testar `docker build` da `orders-api`)
- Editor de preferência
- IA de preferência aberta/logada (Cursor/Copilot/Claude Code/ChatGPT/etc...)
