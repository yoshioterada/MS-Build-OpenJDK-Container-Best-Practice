#!/bin/bash
set -e

# Load Environment Variables
configure_parameters() {
  source ./0-ACA-config-env-values.sh
}

# Delete Azure Container Apps Instance
delete_container_apps_instance(){
    az containerapp delete --name $CUSTOMEJRE_APPLICATION_NAME --resource-group $RESOURCE_GROUP --yes
}

# Delete Azure Container Apps Environment
delete_container_apps_env(){
    az containerapp env delete --name $CUSTOMEJRE_CONTAINER_APPS_ENVIRONMENT --resource-group $RESOURCE_GROUP --yes
}

# Delete Log Analytics Workspace
delete_log_analytics_workspace(){
    az monitor log-analytics workspace delete --resource-group $RESOURCE_GROUP --workspace-name $CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE --yes
}

# Delete Resource Group
delete_resource_group(){
    az group delete --name $RESOURCE_GROUP --yes
}

# Main Operation
configure_parameters;
# delete_container_apps_instance;
# delete_container_apps_env;
# delete_log_analytics_workspace;
delete_resource_group
