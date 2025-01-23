# 30 Days DevOps challenge Week2 - Day 1
## NFL Schedule API
This project provides an API to fetch the NFL schedule using SerpAPI and Flask. The application is containerized using Docker and deployed on Azure Container Apps with API Management using Azure API Management Service.

## Table of Contents

- Installation
- Usage
- Deployment
- API Endpoints
- Environment Variables


## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/nfl-schedule-api.git
    cd nfl-schedule-api
    ```

2. Create a virtual environment and activate it:
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3. Install the dependencies:
    ```bash
    pip install -r requirements.txt
    ```

4. Create a `.env` file and add your SerpAPI key:
    ```env
    SPORTS_API_KEY=your_serpapi_key
    ```

## Usage

1. Run the Flask application:
    ```bash
    python app.py
    ```

2. Access the API at `http://localhost:8080/sports`.

## Deployment

### Docker

1. Build the Docker image:
    ```bash
    docker build -t nfl-schedule-api .
    ```

2. Run the Docker container:
    ```bash
    docker run -p 8080:8080 nfl-schedule-api
    ```

### Azure Container Apps

1. Create a resource group:
    ```bash
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

2. Create a container registry:
    ```bash
    az acr create --resource-group $RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Standard --admin-enabled true
    ```

3. Log in to the container registry:
    ```bash
    az acr login --name $CONTAINER_REGISTRY
    ```

4. Tag and push your Docker image:
    ```bash
    docker tag nfl-schedule-api $CONTAINER_REGISTRY.azurecr.io/nfl-schedule-api:v1
    docker push $CONTAINER_REGISTRY.azurecr.io/nfl-schedule-api:v1
    ```

5. Create a Container Apps environment:
    ```bash
    az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION
    ```

6. Deploy your container app:
    ```bash
    az containerapp create \
     --name $CONTAINER_APP  \
     --resource-group $RESOURCE_GROUP \
     --image $CONTAINER_REGISTRY.azurecr.io/nfl-schedule-api:v1 \
     --environment $ENVIRONMENT \
     --ingress external \
     --registry-server $CONTAINER_REGISTRY.azurecr.io \
     --query properties.configuration.ingress.fqdn
    ```

7. Add scaling rules:
    ```bash
    az containerapp update --name $CONTAINER_APP \
     --resource-group $RESOURCE_GROUP \
     --scale-rule-name http-rule \
     --scale-rule-type http \
     --scale-rule-metadata concurrentRequests=50 \
     --min-replicas 2 \
     --max-replicas 3
    ```

### API Management

1. Create API Management service:
    ```bash
    az apim create --name $APIM_NAME \
                   --resource-group $RESOURCE_GROUP \
                   --location $LOCATION \
                   --sku-name 'Consumption' \
                   --publisher-name "$COMPANY_NAME" \
                   --publisher-email $ADMIN_EMAIL \
                   --enable-client-certificate false \
                   --enable-managed-identity false 
    ```

2. Get Container App URL:
    ```bash
    CONTAINER_APP_URL=$(az containerapp show \
        --name $CONTAINER_APP \
        --resource-group $RESOURCE_GROUP \
        --query "properties.configuration.ingress.fqdn" \
        --output tsv)
    ```

3. Create API in API Management:
    ```bash
    az apim api create \
        --resource-group $RESOURCE_GROUP \
        --service-name $APIM_NAME \
        --api-id "$CONTAINER_APP-api" \
        --path "/$CONTAINER_APP" \
        --display-name "$CONTAINER_APP API" \
        --protocols https \
        --service-url "https://$CONTAINER_APP_URL" \
        --subscription-required false
    ```

4. Create API operation:
    ```bash
    az apim api operation create \
        --resource-group $RESOURCE_GROUP \
        --service-name $APIM_NAME \
        --api-id "$CONTAINER_APP-api" \
        --operation-id get-items \
        --display-name "Get Items" \
        --method GET \
        --url-template "sports" \
        --description "Trigger a get request for /sports"
    ```

## API Endpoints

- `GET /sports`: Fetches the NFL schedule.

## Environment Variables

- `SPORTS_API_KEY`: Your SerpAPI key.

