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

        stage('Sonar Analysis') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    echo "==> Performing SonarQube Scan"

                    script {
                        def scannerHome = tool 'SonarQube Tool';
                        withSonarQubeEnv('SonarQube') {
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                    }

                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            agent { label 'docker-machine' }

            steps {
                unstash "${WAR_NAME}"
                unstash "${JAR_NAME}"

                sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --build-arg JAR_FILE=${ARTIFACT_PATH}/${DEPENDENCY_PATH}/${JAR_NAME}.jar --build-arg WAR_FILE=${ARTIFACT_PATH}/${WAR_NAME}.war ."
            }
        }

        stage('Push Image to Registry') {
            agent { label 'docker-machine' }

            steps {
                sh '''
                docker login --username ${DOCKER_HUB_USR} --password ${DOCKER_HUB_PSW}
                docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
            '''
            }
        }

        stage('Deploy to EKS') {
            agent { label 'docker-machine' }

            steps {
                dir('.aws') {
                    withCredentials([file(credentialsId: 'aws-credentials', variable: 'credentialsEnv')]) {
                        sh "cat ${credentialsEnv} > credentials"
                    }

                    withCredentials([file(credentialsId: 'aws-config', variable: 'configEnv')]) {
                        sh "cat ${configEnv} > config"
                    }

                    sh "ls -la"
                }
            }
        }
    }
}