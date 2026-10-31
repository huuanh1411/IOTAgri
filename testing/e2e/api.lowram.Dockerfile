FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY backend/IOTAgriBackend.csproj backend/
RUN dotnet restore backend/IOTAgriBackend.csproj --disable-parallel /p:BuildInParallel=false
COPY backend/ backend/
RUN dotnet publish backend/IOTAgriBackend.csproj --no-restore -c Release -o /app/publish /m:1 /p:BuildInParallel=false /p:UseSharedCompilation=false /p:UseAppHost=false
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=build --chown=app:app /app/publish .
USER app
ENTRYPOINT ["dotnet", "IOTAgriBackend.dll"]
