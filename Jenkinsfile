pipeline {
    agent { label 'master' }

    environment {
        DOCKER_IMAGE_NAME = "kassielbatista/yara-helloworld"
        DOCKER_IMAGE_TAG = "latest"
        MVN_OPTS = "-Dmaven.repo.local=${WORKSPACE} -Dmaven.test.failure.ignore=true"
        ARTIFACT_PATH = "target"
        DEPENDENCY_PATH = "dependency"
        WAR_NAME = "helloworld"
        JAR_NAME = "jetty-runner"
        DOCKER_HUB = credentials("docker-hub-login")
    }

    tools {
        maven 'Maven 3.6.3'
        jdk 'jdk8'
    }

    stages {
        stage('Build Project') {
            agent { label 'master' }

            steps {
                sh "mvn clean package"

                stash includes: "${ARTIFACT_PATH}/${WAR_NAME}.war", name: "${WAR_NAME}"
                stash includes: "${ARTIFACT_PATH}/${DEPENDENCY_PATH}/${JAR_NAME}.jar", name: "${JAR_NAME}"
            }
        }

//         stage('Execute Tests') {
//             steps {
//                 sh "mvn ${MVN_OPTS} test"
//             }
//             post {
//                 always {
//                     junit "${PROJECT_DIR}/${ARTIFACT_PATH}/surefire-reports/*.xml"
//                     step( [ $class: 'JacocoPublisher' ] )
//                 }
//             }
//         }

        stage('Build Docker Image') {
            agent { label 'docker-machine' }

            steps {
                unstash "${WAR_NAME}"
                unstash "${JAR_NAME}"

                sh "docker build -f Dockerfile-ci -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}/${DOCKER_IMAGE_TAG} --build-arg JAR_FILE=${ARTIFACT_PATH}/${DEPENDENCY_PATH}/${JAR_NAME}.jar --build-arg WAR_FILE=${ARTIFACT_PATH}/${WAR_NAME}.war ."
            }
        }

        stage('Push Image to Registry') {
            agent {label 'docker-machine' }

            steps {
                sh '''
                docker login --username ${DOCKER_HUB_USR} --password ${DOCKER_HUB_PSW}
                docker push ${DOCKER_IMAGE_NAME}/${DOCKER_IMAGE_TAG}
            '''
            }
        }
    }
}