# orders-api

ASP.NET Core 8 Web API gerada a partir do template oficial `dotnet new webapi`
(open source, MIT — `dotnet/sdk`). Esta é a aplicação de exemplo do desafio:
você **não precisa entender ou alterar o código C#** — seu trabalho é
infra, container e CI/CD em volta dela.

## Endpoints

- `GET /weatherforecast` — endpoint de exemplo do template, retorna JSON
- `GET /health` — health check (200 OK quando a app está viva)
- `GET /swagger` — UI do Swagger (apenas em `Development`)

## Rodar local (sem Docker)

```bash
dotnet run
```

Sobe em `http://localhost:5132` por padrão (ver `Properties/launchSettings.json`).

## Rodar em container

A imagem deve usar:

- **build:** `mcr.microsoft.com/dotnet/sdk:8.0`
- **runtime:** `mcr.microsoft.com/dotnet/aspnet:8.0`
- **porta:** `8080` (default do container `aspnet:8.0` no .NET 8)

Variáveis úteis:

- `ASPNETCORE_URLS=http://+:8080` — força a app a escutar na porta certa
- `ASPNETCORE_ENVIRONMENT=Production` — desliga Swagger

## O que esta app **não** faz (de propósito)

- Não conecta no Postgres — o `Deployment` deve estar **preparado** para
  receber a connection string via `ConfigMap`/`Secret`/Key Vault, mas a
  app não usa de fato.
- Não escreve em Storage — mesmo princípio.

O foco do desafio é a infra e o pipeline em volta, não a aplicação.
