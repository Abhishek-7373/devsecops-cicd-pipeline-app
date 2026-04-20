pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')

        IMAGE_NAME = "devsecops-app"
        IMAGE_TAG = "latest"

        SONAR_HOST_URL = "http://172.31.15.27:9000"
        EC2_HOST = "172.31.15.27"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git url: 'https://github.com/Abhishek-7373/devsecops-cicd-pipeline-app.git', branch: 'main'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=devsecops-project \
                        -Dsonar.projectName=DevSecOps-Project \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Docker Push') {
            steps {
                sh """
                    echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} '
                            docker pull ${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG} &&
                            docker stop app || true &&
                            docker rm app || true &&
                            docker run -d --name app -p 3000:3000 ${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG}
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "PIPELINE SUCCESS - DevSecOps flow completed"
        }
        failure {
            echo "PIPELINE FAILED - check logs"
        }
    }
}
