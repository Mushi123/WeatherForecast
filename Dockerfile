# FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
# WORKDIR /app
# EXPOSE 80

# ENV ASPNETCORE_URLS=http://+:80

# FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
# WORKDIR /src
# COPY ["src/Samples.WeatherForecast.Api/Samples.WeatherForecast.Api.csproj", "src/Samples.WeatherForecast.Api/"]
# RUN dotnet restore "src/Samples.WeatherForecast.Api/Samples.WeatherForecast.Api.csproj"
# COPY . .
# WORKDIR "/src/src/Samples.WeatherForecast.Api"
# RUN dotnet build "Samples.WeatherForecast.Api.csproj" -c Release -o /app/build

# FROM build AS publish
# RUN dotnet publish "Samples.WeatherForecast.Api.csproj" -c Release -o /app/publish

# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "Samples.WeatherForecast.Api.dll"]

# FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
# WORKDIR /app
# EXPOSE 80

# ENV ASPNETCORE_URLS=http://+:80

# FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
# WORKDIR /app
# COPY . .
# WORKDIR "/app/src/Samples.WeatherForecast.Api"
# RUN dotnet restore "Samples.WeatherForecast.Api.csproj"
# RUN dotnet build "Samples.WeatherForecast.Api.csproj" -c Release -o /app/build --no-restore

# FROM build AS publish
# RUN dotnet publish "Samples.WeatherForecast.Api.csproj" -c Release -o /app/publish

# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "Samples.WeatherForecast.Api.dll"]


ARG VERSION=6.0

FROM mcr.microsoft.com/dotnet/sdk:${VERSION} AS build
WORKDIR /app

# Copy and restore as distinct layers
COPY . .
WORKDIR /app/src/Samples.WeatherForecast.Api
RUN dotnet restore Samples.WeatherForecast.Api.csproj -r osx.10.11-x64

FROM build AS publish
RUN dotnet publish \
    -c Release \
    -o /out \
    -r osx.10.11-x64 \
    --self-contained=true \
    --no-restore \
    -p:PublishReadyToRun=true \
    -p:PublishTrimmed=true

# Final stage/image
FROM mcr.microsoft.com/dotnet/runtime-deps:${VERSION}
WORKDIR /app
COPY --from=publish /out .

EXPOSE 80
ENTRYPOINT ["./Samples.WeatherForecast.Api"]