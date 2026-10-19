FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["backend/IOTAgriBackend.csproj", "backend/"]
RUN dotnet restore "backend/IOTAgriBackend.csproj"
COPY . .
RUN dotnet publish "backend/IOTAgriBackend.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& addgroup --system --gid 10001 app \
	&& adduser --system --uid 10001 --ingroup app app \
	&& chown -R app:app /app
USER app
EXPOSE 8080
ENTRYPOINT ["dotnet", "IOTAgriBackend.dll"]
