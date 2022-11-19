#!/bin/bash
set -e

if [ "$1" = "" ]
then
    echo "./create-and-used-custom-jre.sh [version-number]"
    echo ""
    echo " Example:"
    echo "./create-and-used-custom-jre.sh 15"
    exit 1
fi
export VERSION=$1

###############################################################
# Automatic Source Code Change (This is test purpose only)
#
# This function automaticaly replaced the VERSION value 
# in the following source code.
# 
# @RestController
# public class HelloController {
# 
#     private final static int VERSION=4;
###############################################################
temporary_code_change_for_test_purpose() {
    echo "temporary_code_change_for_test_purpose()  is running ..."
    sed -i -e "s/private final.*/private final static int VERSION=${VERSION};/g" ../src/main/java/com/yoshio3/HelloController.java
    rm ../src/main/java/com/yoshio3/HelloController.java-e
}

###############################################################
# 1. 環境設定の読み込み
#
# Load the environment variables
###############################################################
configure_parameters() {
    export CUSTOMEJRE_DOCKER_IMAGE=tyoshio2002/custome-jre-used-service
    export DOCKERFILE_NAME_FOR_CUSTOM_JRE=Dockerfile-create-custom-jre-inside-for-LT2
    export DOCKER_REPOSITORY=yoshio.azurecr.io
}

###############################################################
# 2. Java のソースコードのビルド
#
# Build the Java Source Code
###############################################################
build_java_source_code() {
    echo "build_java_source_code()  is running ..."
    # Build Java Source Code
    mvn clean package -f ../pom.xml -DskipTests
}

###############################################################
# 5. カスタム JRE 及び 本番サービス用のコンテナ・イメージを作成 
#
# Compare the dependency with the previous version
# If there is a difference in the module lists, 
# the new version of the CustomJRE image will be created
###############################################################
build_and_push_docker_image(){
    echo "build_and_push_docker_image()  is running ..."
    # Build Docker Image for Custom JRE
    docker build -t $CUSTOMEJRE_DOCKER_IMAGE:$VERSION .. -f $DOCKERFILE_NAME_FOR_CUSTOM_JRE
    docker tag $CUSTOMEJRE_DOCKER_IMAGE:$VERSION $DOCKER_REPOSITORY/$CUSTOMEJRE_DOCKER_IMAGE:$VERSION
    docker push $DOCKER_REPOSITORY/$CUSTOMEJRE_DOCKER_IMAGE:$VERSION
}

# Main Operation
###############################################################
temporary_code_change_for_test_purpose

configure_parameters;
build_java_source_code;
build_and_push_docker_image;
