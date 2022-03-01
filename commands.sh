# Dockerfile_0: Trip Insights - User (Java) API
# Dockerfile_1: Trip Insights - TripViewer Site
# Dockerfile_2: Trip Insights - User Profile API
# Dockerfile_3: Trip Insights - POI (Points Of Interest) API
# Dockerfile_4: Trip Insights - Trips API

# Authenticate
az login --use-device-code
az acr login --name registryhku7094

# Build the app container
cd src/poi
docker build -t poi --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/Dockerfile_3 .

cd ../trips
docker build -t trips --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/Dockerfile_4 .

cd ../tripviewer
docker build -t tripviewer --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/Dockerfile_1 .

cd ../user-java
docker build -t user-java --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/Dockerfile_0 .

cd ../userprofile
docker build -t userprofile --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f ../../dockerfiles/Dockerfile_2 .

# Create local SQL server container
docker pull mcr.microsoft.com/mssql/server:2017-latest
docker run -d --network bridge -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=MyStrongXYZPassw0rd123" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2017-latest

#
# IMPORTANT!
#
# Depending on your setup, you're containers will be exposed over localhost to your machine.
# If you're running these commands inside a devcontainer, localhost might not work.
# You have to run any commands that involve localhost on your local machine OR use the IP address of the container
# Find that with: 
# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' poi
# for the IP address of the poi container
#

# Login to container
docker exec -it sql1 /bin/bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "MyStrongXYZPassw0rd123"

# Create database
## Run in your sqlcmd session
CREATE DATABASE mydrivingDB;
GO
exit

# Use the IP address to load the data into the DB
docker run -d --name dataload --network bridge -e SQLFQDN=localhost -e SQLUSER=sa -e SQLPASS=MyStrongXYZPassw0rd123 -e SQLDB=mydrivingDB registryhku7094.azurecr.io/dataload:1.0

## START Run containers
# Run the API container
docker run -d -p 8080:80 --name poi --network bridge -e SQL_SERVER=localhost -e SQL_USER=sa -e SQL_PASSWORD=MyStrongXYZPassw0rd123 -e SQL_DBNAME=mydrivingDB -e ASPNETCORE_ENVIRONMENT=local poi:latest 

# Run the trips container
docker run -d -p 8081:80 --name trips --network bridge -e SQL_SERVER=localhost -e SQL_USER=sa -e SQL_PASSWORD=MyStrongXYZPassw0rd123 -e SQL_DBNAME=mydrivingDB -e OPENAPI_DOCS_URI=http://localhost trips:latest

# Run the tripviewer container
docker run -d --name tripviewer --network bridge -e TRIPS_API_ENDPOINT=http://localhost:8081 -e USERPROFILE_API_ENDPOINT=http://localhost:8083 tripviewer:latest

# Run the user-java container
docker run -d -p 8082:80 --name user-java --network bridge -e SQL_SERVER=localhost -e SQL_USER=sa -e SQL_PASSWORD=MyStrongXYZPassw0rd123 -e SQL_DBNAME=mydrivingDB user-java:latest

# Run the userprofile container
docker run -d -p 8083:80 --name userprofile --network bridge -e SQL_SERVER=localhost -e SQL_USER=sa -e SQL_PASSWORD=MyStrongXYZPassw0rd123 -e SQL_DBNAME=mydrivingDB userprofile:latest
## END Run containers

# Check if the API works
curl -i -X GET 'http://localhost:8080/api/poi/healthcheck'

# Push to the container registry
docker tag poi registryhku7094.azurecr.io/poi-jvr
docker push registryhku7094.azurecr.io/poi-jvr

docker tag trips registryhku7094.azurecr.io/trips-jvr
docker push registryhku7094.azurecr.io/trips-jvr

docker tag tripviewer registryhku7094.azurecr.io/tripviewer-jvr
docker push registryhku7094.azurecr.io/tripviewer-jvr

docker tag user-java registryhku7094.azurecr.io/user-java-jvr
docker push registryhku7094.azurecr.io/user-java-jvr

docker tag userprofile registryhku7094.azurecr.io/userprofile-jvr
docker push registryhku7094.azurecr.io/userprofile-jvr
# Build the other containers