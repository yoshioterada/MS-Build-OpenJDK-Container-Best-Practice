#!/bin/bash
set -e

if [ "$1" = "" ]
then
    echo "./create-reused-custom-jre-first.sh [version-number]"
    echo ""
    echo " Example:"
    echo "./create-reused-custom-jre-first.sh 15"
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
    echo "configure_parameters()  is running ..."
    source ./0-ACA-config-env-values.sh
    export DOCKERFILE_NAME_FOR_PRODUCTION_IMAGE=Dockerfile-production-service-for-LT3_4 
}

###############################################################
# 2. Java のソースコードのビルド
#
# Build the Java Source Code
###############################################################
build_java_source_code() {
    echo "build_java_source_code()  is running ..."
    # Build Java Source Code
    mvn clean package -DskipTests  -f ../pom.xml -DskipTests
}

###############################################################
# 3. jdeps コマンドを実行し、依存モジュールの一覧を作成
#
# Execute the jdeps command and store the result to "diff-result" directory
###############################################################
exec_jdeps_command_create_lists_of_dependency_modules(){
    echo "exec_jdeps_command_create_lists_of_dependency_modules()  is running ..."
    mkdir -p $DEPS_RESULT_DIR_NAME

    # Get the file name of the latest version of the jdeps command
    export PREVIOUS_VERSION=$(ls -t $DEPS_RESULT_DIR_NAME| head -n 1)
    pwd
    # Execute jdeps command and store the result
    jar -xf ../target/$APPLICATION_ARTIFACT_NAME 
    mv BOOT-INF META-INF org ../target/
    jdeps \
        --ignore-missing-deps \
        --print-module-deps \
        -q \
        --recursive \
        --multi-release 17 \
        --class-path="../target/BOOT-INF/lib/*" \
        --module-path="../target/BOOT-INF/lib/*" \
        ../target/$APPLICATION_ARTIFACT_NAME  > ./$DEPS_RESULT_DIR_NAME/deps-info-${VERSION}.txt
    # Create deps-info-latest.txt file which is used on Dockerfile "COPY" command
    cp ./$DEPS_RESULT_DIR_NAME/deps-info-${VERSION}.txt ./$DEPS_RESULT_DIR_NAME/$FILE_NAME_OF_LATEST_VERSION
    touch ./$DEPS_RESULT_DIR_NAME/deps-info-${VERSION}.txt
}

###############################################################
# 4. CDS (Class Data Sharing) のライブラリを作成
# 
# Create Class Data Sharing (CDS) libs file
###############################################################
create_libs_for_class_data_sharing_of_java(){
    echo "create_libs_for_class_data_sharing_of_java()  is running ..."
    timeout -k 3s 5s java -XX:ArchiveClassesAtExit=../target/my-shared-libs-production.jsa -jar ../target/$APPLICATION_ARTIFACT_NAME &
    sleep 10
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

    # Update the Docker Image Tag VERSION in Dockerfile-4-production-service
    sed -i -e "s/FROM $DOCKER_REPOSITORY\/$DOCKER_IMAGE_NAME_PREFIX\/$DOCKER_IMAGE_NAME_FOR_CUSTOM_JRE:.*/FROM $DOCKER_REPOSITORY\/$DOCKER_IMAGE_NAME_PREFIX\/$DOCKER_IMAGE_NAME_FOR_CUSTOM_JRE:${VERSION} AS CUSTOM-JRE/g" $DOCKERFILE_NAME_FOR_PRODUCTION_IMAGE
    rm $DOCKERFILE_NAME_FOR_PRODUCTION_IMAGE-e

    # Build Docker Image for Java Application
    docker build -t $CUSTOMEJRE_APP_DOCKER_IMAGE:$VERSION .. -f $DOCKERFILE_NAME_FOR_PRODUCTION_IMAGE
    docker tag $CUSTOMEJRE_APP_DOCKER_IMAGE:$VERSION $DOCKER_REPOSITORY/$CUSTOMEJRE_APP_DOCKER_IMAGE:$VERSION
    docker push $DOCKER_REPOSITORY/$CUSTOMEJRE_APP_DOCKER_IMAGE:$VERSION
}



# Main Operation
###############################################################
temporary_code_change_for_test_purpose

configure_parameters;
build_java_source_code;
exec_jdeps_command_create_lists_of_dependency_modules;

#create_libs_for_class_data_sharing_of_java
build_and_push_docker_image;
