# ============================================================
# Stage 1 — Build
# ============================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia apenas o .csproj primeiro para aproveitar cache de restore
COPY orders-api/orders-api.csproj ./orders-api/
RUN dotnet restore ./orders-api/orders-api.csproj

# Copia o restante do código e publica em modo Release
COPY orders-api/ ./orders-api/
RUN dotnet publish ./orders-api/orders-api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ============================================================
# Stage 2 — Runtime
# ============================================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Porta padrão do ASP.NET 8 em container
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

# Copia os artefatos publicados do stage de build
COPY --from=build /app/publish .

# A imagem aspnet:8.0 já roda como usuário 'app' (não-root) por padrão.
# Não redefinimos USER para não desfazer isso.

# Health check via wget (disponível na imagem Debian-based do aspnet)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "orders-api.dll"]
