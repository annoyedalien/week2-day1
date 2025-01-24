# 30 Days DevOps challenge Week2 - Day 1
## NFL Schedule API
This project provides an API to fetch the NFL schedule using SerpAPI and Flask. The application is containerized using Docker and deployed on Azure Container Apps with API Management using Azure API Management Service.

## Table of Contents

- Prerequisite
- Installation
- Docker build
- Resource Provision
- Test

## Prerequisites
- Python / Flask
- Azure Account
- Azure CLI
- VS Code (Optional)
- Docker CLI / Desktop
  
## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/annoyedalien/week2-day1.git
    cd week2-day1
    ```

2. Create a `.env` file and add your SerpAPI key:
    ```env
    SPORTS_API_KEY=your_serpapi_key
    ```



### Docker
1. Verify the details of the Dockerfile

2. Build the Docker image:
	```bash
    docker build -t flask-app .
	```

### Update the variables of resource.sh
```bash
vim resource.sh
```

```bash
# Variables
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
```
Save and exit vim editor.

### Run resource.sh script
The script will create the following Azure resources
- Resource Group
- Azure Container registry
- Push the docker image from local to azure container registry
- Environment workspace for Container Apps
- Azure Container Apps + Replicas of the container + Scaling Metrics
- API Management service
- API for the Container App
- API Operation GET

### Test
Copy the URL link on the API Management service 
https://[api_management_service_name].azure-api.net/day4containerapp/sports

## Environment Variables

- `SPORTS_API_KEY`: Your SerpAPI key.

