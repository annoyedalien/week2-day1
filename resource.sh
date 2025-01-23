#!/bin/bash

# Variables for  the shell script
RESOURCE_GROUP="Resource Group Name"
CONTAINER_REGISTRY="Container Registry Name"
CONTAINER_APP="Container App Name"
ENVIRONMENT="Environment Name"
LOCATION="Region"
IMAGE_NAME="Docker Image Name"

APIM_NAME="API Management Service Name"
SKU="Consumption/Standard/Premium"
COMPANY_NAME="Your Company Name"
ADMIN_EMAIL="Your Email"


# Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a container registry
az acr create --resource-group $RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Standard --admin-enabled true

# Log in to the container registry
az acr login --name $CONTAINER_REGISTRY

# Tag your Docker image
docker tag $IMAGE_NAME $CONTAINER_REGISTRY.azurecr.io/$IMAGE_NAME:v1

# Push the Docker image to the registry
docker push $CONTAINER_REGISTRY.azurecr.io/$IMAGE_NAME:v1


# Create a Container Apps environment
az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION

# Deploy your container app
az containerapp create \
 --name $CONTAINER_APP  \
 --resource-group $RESOURCE_GROUP \
 --image $CONTAINER_REGISTRY.azurecr.io/$IMAGE_NAME:v1 \
 --environment $ENVIRONMENT \
 --ingress external \
 --registry-server $CONTAINER_REGISTRY.azurecr.io \
 --query properties.configuration.ingress.fqdn

# Add scaling rules
az containerapp update --name $CONTAINER_APP \
 --resource-group $RESOURCE_GROUP \
 --scale-rule-name http-rule \
 --scale-rule-type http \
 --scale-rule-metadata concurrentRequests=50 \
 --min-replicas 2 \
 --max-replicas 3

# Create API Management service
az apim create --name $APIM_NAME \
               --resource-group $RESOURCE_GROUP \
               --location $LOCATION \
               --sku-name 'Consumption' \
               --publisher-name "$COMPANY_NAME" \
               --publisher-email $ADMIN_EMAIL \
               --enable-client-certificate false \
               --enable-managed-identity false 



# Create the API from the Azure resource (Container App)
az apim api create --resource-group $RESOURCE_GROUP \
                   --service-name $APIM_NAME \
                   --display-name $CONTAINER_APP \
                   --api-id $CONTAINER_APP \
                   --path "/$CONTAINER_APP" \
                   --service-url "https://"$CONTAINER_APP_URL \
                   --protocols https

# First ensure APIM exists
az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP

# Get Container App URL
CONTAINER_APP_URL=$(az containerapp show \
    --name $CONTAINER_APP \
    --resource-group $RESOURCE_GROUP \
    --query "properties.configuration.ingress.fqdn" \
    --output tsv)

# Create API in APIM
az apim api create \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --api-id "$CONTAINER_APP-api" \
    --path "/$CONTAINER_APP" \
    --display-name "$CONTAINER_APP API" \
    --protocols https \
    --service-url "https://$CONTAINER_APP_URL" \
    --subscription-required false


# Create API operation
az apim api operation create \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --api-id "$CONTAINER_APP-api" \
    --operation-id get-items \
    --display-name "Get Items" \
    --method GET \
    --url-template "sports" \
    --description "Trigger a get request for /sports"
