# Base ASP.NET runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build stage with Node.js and .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Install Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Copy project files
COPY ["Dormo.Server/Dormo.Server.csproj", "Dormo.Server/"]
COPY ["dormo.client/dormo.client.esproj", "dormo.client/"]
COPY ["dormo.client/package.json", "dormo.client/"]

# Install Node.js dependencies first
WORKDIR /src/dormo.client
RUN npm install

# Build .NET project
WORKDIR /src
RUN dotnet restore "./Dormo.Server/Dormo.Server.csproj"
COPY . .
WORKDIR "/src/Dormo.Server"
ARG BUILD_CONFIGURATION=Release
RUN dotnet build "./Dormo.Server.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Dormo.Server.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Dormo.Server.dll"]