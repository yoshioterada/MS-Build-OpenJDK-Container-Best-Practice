##################################################
# Azure Related Variables
##################################################
# The name of Resource Group
export RESOURCE_GROUP="java-container-apps"
# Install Location
export LOCATION="japaneast"

# The name of Log Analytics Workspace
export CUSTOMEJRE_LOG_ANALYTICS_WORKSPACE="java-custom-jre-logs"

# The name of Container Apps Environment
export CUSTOMEJRE_CONTAINER_APPS_ENVIRONMENT="java-custom-jre-env"

export CUSTOMEJRE_APPLICATION_NAME="custom-jre-app"

##################################################
# Container Related Variables
##################################################
export DOCKER_REPOSITORY=yoshio.azurecr.io
export DOCKER_IMAGE_NAME_PREFIX=tyoshio2002
export DOCKER_IMAGE_NAME_FOR_CUSTOM_JRE=custom-jre
# If you change the name of the above variable, 
# You need change the Dockerfile-4-production as well.

export DOCKERFILE_NAME_FOR_CUSTOM_JRE="Dockerfile-create-custom-jre-outside"
# The name of Dockerfile for creating the Java Application Image
export DOCKERFILE_NAME_FOR_PRODUCTION_IMAGE="Dockerfile-production-service-for-ACA2_4"

# Name of Custom JRE Image 
export CUSTOMEJRE_DOCKER_IMAGE=$DOCKER_IMAGE_NAME_PREFIX/$DOCKER_IMAGE_NAME_FOR_CUSTOM_JRE
export CUSTOMEJRE_APP_DOCKER_IMAGE=$DOCKER_IMAGE_NAME_PREFIX/$CUSTOMEJRE_APPLICATION_NAME

##################################################
# Application Related Variables
##################################################
# The name of Artifact of Java Applicaiton (target/*.jar)
export APPLICATION_ARTIFACT_NAME="custom-jre-sample-0.0.1-SNAPSHOT.jar"

# Following is the directory name which store the result of jdeps command
export DEPS_RESULT_DIR_NAME="diff-result"
# The name of result of latest version of jdeps (This will be used on Dockerfile COPY command)
export FILE_NAME_OF_LATEST_VERSION="deps-info-latest.txt"
