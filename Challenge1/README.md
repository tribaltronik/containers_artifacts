# Challenge 1

Fork Repo
https://github.com/tribaltronik/containers_artifacts


## Objectives


# SQL Server

You’ll need to authenticate to the registry first - reference the Azure Container Registry resource in the Azure portal for registry credentials.

## Login Registry
registryhku7094.azurecr.io
registryhku7094
kxFnUa6icnNYVAOkm5fI/2Meonh0PCqd

az login

## Login to registry by command line
az acr login --name registryhku7094

## command

### Create network
 docker network create huminsnet

### SQL Server
docker run -d --network huminsnet -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=humins5erv1ce'  --name 'mydrivingDB' -p 1433:1433 mcr.microsoft.com/mssql/server:2017-latest

### Create DB running command inside container
docker exec mydrivingDB /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'humins5erv1ce' -Q "CREATE DATABASE mydrivingDB"

### Update database
docker run --network huminsnet -e SQLFQDN=mydrivingDB -e SQLUSER=SA -e SQLPASS=humins5erv1ce -e SQLDB=mydrivingDB registryhku7094.azurecr.io/dataload:1.0


# POI API

### Build
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f ..\..\dockerfiles\Dockerfile_3 -t "tripinsights/poi:1.0" .

## Run and test
 docker build -t tripinsights/poi -f ..\..\dockerfiles\Dockerfile_3 .

  docker run -d --network huminsnet -p 8080:80 --name poi -e "SQL_PASSWORD=humins5erv1ce" -e "SQL_SERVER=mydrivingDB" -e "SQL_USER=SA" -e "ASPNETCORE_ENVIRONMENT=Local"  tripinsights/poi

  
### Push image to ACR



docker tag tripinsights/poi:1.0 registryhku7094.azurecr.io/tripinsights/poi_tr:1.0

docker push registryhku7094.azurecr.io/tripinsights/poi_tr:1.0


# Trip Viewer (UI)

Powershell
```powershell
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f ..\..\dockerfiles\Dockerfile_1 -t "tripinsights/tripviewer:1.0" .
```
## Run and test
docker run -d -p 80:80 --name tripviewer -e "USERPROFILE_API_ENDPOINT=http://localhost:8083" -e "TRIPS_API_ENDPOINT=http://localhost:8081" tripinsights/tripviewer:1.0


## Tag and push
docker tag tripinsights/tripviewer:1.0 registryhku7094.azurecr.io/tripinsights/tripviewer_tr:1.0

docker push registryhku7094.azurecr.io/tripinsights/tripviewer_tr:1.0


docker run -d --network huminsnet -p 80:80 --name tripviewer tripinsights/tripviewer:1.0
docker run -d -p 8080:80 --name tripviewer -e "USERPROFILE_API_ENDPOINT=http://$ENDPOINT" -e "TRIPS_API_ENDPOINT=http://$ENDPOINT" tripinsights/tripviewer:1.0


# Trips API (go)

Powershell
```powershell
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f ..\..\dockerfiles\Dockerfile_4 -t "tripinsights/trips:1.0" .
```
## Run and test
docker run -d -p 8081:80 --name trips -e "SQL_PASSWORD=humins5erv1ce" -e "SQL_SERVER=mydrivingDB" -e "OPENAPI_DOCS_URI=http://$EXTERNAL_IP" tripinsights/trips:1.0

curl -i -X GET 'http://localhost:8081/api/trips/healthcheck'

## Tag and push
docker tag tripinsights/trips:1.0 registryhku7094.azurecr.io/tripinsights/trips_tr:1.0

docker push registryhku7094.azurecr.io/tripinsights/trips_tr:1.0


# User-java

## Build
Powershell
```powershell
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f ..\..\dockerfiles\Dockerfile_0 -t "tripinsights/user-java:1.0" .
```
## Run and test
docker run -d -p 8082:80 --network huminsnet --name user-java -e "SQL_USER=SA" -e "SQL_DBNAME=mydrivingDB" -e "SQL_PASSWORD=humins5erv1ce" -e "SQL_SERVER=mydrivingDB" tripinsights/user-java:1.0

curl -i -X GET 'http://localhost:8082/api/user-java/healthcheck'

## Tag and push
docker tag tripinsights/user-java:1.0 registryhku7094.azurecr.io/tripinsights/user-java_tr:1.0

docker push registryhku7094.azurecr.io/tripinsights/user-java_tr:1.0

# Userprofile (nodejs)

## Build
docker build -t "tripinsights/trips:1.0" -f ..\..\dockerfiles\Dockerfile_4 .

Powershell
```powershell
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f ..\..\dockerfiles\Dockerfile_2 -t "tripinsights/userprofile:1.0" .
```

## Run and test
docker run -d -p 8083:80 --name userprofile -e "SQL_PASSWORD=humins5erv1ce" -e "SQL_SERVER=mydrivingDB" tripinsights/userprofile:1.0

curl -i -X GET 'http://localhost:8083/api/user/healthcheck'

## Tag and push
docker tag tripinsights/userprofile:1.0 registryhku7094.azurecr.io/tripinsights/userprofile_tr:1.0

docker push registryhku7094.azurecr.io/tripinsights/userprofile_tr:1.0

