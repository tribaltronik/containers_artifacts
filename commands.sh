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
docker build -t poi -f ..\..\dockerfiles\Dockerfile_3 .

# Create local SQL server container
docker pull mcr.microsoft.com/mssql/server:2017-latest
docker run --network bridge -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=MyStrongXYZPassw0rd123" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2017-latest

# Login to container
docker exec -it sql1 /bin/bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "MyStrongXYZPassw0rd123"

# Create database
## Run in your sqlcmd session
CREATE DATABASE mydrivingDB;
GO
exit

# Get IP address of container
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sql1

# Use the IP address to load the data into the DB
docker run --network bridge -e SQLFQDN=172.17.0.3 -e SQLUSER=sa -e SQLPASS=MyStrongXYZPassw0rd123 -e SQLDB=mydrivingDB registryhku7094.azurecr.io/dataload:1.0

# Run the API container
docker run --network bridge -e SQL_SERVER=172.17.0.3 -e SQL_USER=sa -e SQL_PASSWORD=MyStrongXYZPassw0rd123 -e SQL_DBNAME=mydrivingDB poi:latest
