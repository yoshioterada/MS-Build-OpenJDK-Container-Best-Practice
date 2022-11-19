#!/bin/bash
set -e

# Load Environment Variables
configure_parameters() {
  source ./0-ACA-config-env-values.sh
}

show_logs(){
  echo "#"
  echo "# If following message is shown, please re-execute some times until show the logs."
  echo "# Error Message Sample: \"BadArgumentError: The request had some invalid properties\""
  echo "#"

  export CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE -o tsv | tr -d '[:space:]'`  
  # Log Check Command
  # echo "Container Console Logs----------------------------------------"
  # az monitor log-analytics query \
  #   -w $CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  #   --analytics-query "ContainerAppConsoleLogs_CL| where TimeGenerated > ago(10m) | where ContainerAppName_s == '$CUSTOMEJRE_APPLICATION_NAME' | project Log_s | take 500" -o tsv
  # echo "Container Console Logs----------------------------------------"
  echo "------------------ Container Apps System Logs ------------------"
  export CUSTOMJRE_INSTANCE_NAME=$(az containerapp revision list \
      --resource-group $RESOURCE_GROUP \
      -n $CUSTOMEJRE_APPLICATION_NAME \
      --query "[].name" -o tsv)
  az monitor log-analytics query \
    -w $CUSTOMJRE_LOG_ANALYTICS_WORKSPACE_CLIENT_ID  \
    --analytics-query "ContainerAppSystemLogs_CL | where RevisionName_s == '$CUSTOMJRE_INSTANCE_NAME' | project TimeGenerated, Log_s, Reason_s, RevisionName_s | sort by TimeGenerated asc" -o table
  echo "------------------ Container Apps System Logs ------------------"
}

# Main Operation
###############################################################
configure_parameters;
show_logs;