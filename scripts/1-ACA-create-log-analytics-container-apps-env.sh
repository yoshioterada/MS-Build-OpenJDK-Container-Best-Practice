#!/bin/bash
set -e

# Load Environment Variables
configure_parameters() {
  echo "configure_parameters()  is running ..."
  source ./0-ACA-config-env-values.sh
}

# Create Resource Group
create_resource_group() {
  echo "create_resource_group()  is running ..."
  az group create --name $RESOURCE_GROUP --location $LOCATION
}

# Create Log Analytics Workspace
create_log_analytics_workspace() {
  echo "create_log_analytics_workspace()  is running ..."
  az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION  \
    --workspace-name $CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE
  export CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE -o tsv | tr -d '[:space:]'`
  export CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE -o tsv | tr -d '[:space:]'`  
}

# Create Azure Container Apps Environment
create_azure_container_apps_env(){
  echo "create_azure_container_apps_env()  is running ..."
  az containerapp env create \
    --name $CUSTOMEJRE_CONTAINER_APPS_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --logs-workspace-id $CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
    --logs-workspace-key $CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET \
    --location $LOCATION
}

# Main Operation
#########################################################
configure_parameters;
create_resource_group;
create_log_analytics_workspace;
create_azure_container_apps_env;