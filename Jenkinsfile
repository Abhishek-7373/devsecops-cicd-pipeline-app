pipeline {
    agent any

    environment {
        IMAGE_NAME = "devsecops-app"
        IMAGE_TAG = "latest"

        SONAR_HOST_URL = "http://13.203.200.120:9000"
        EC2_HOST = "13.203.200.120"
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
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            sonar-scanner \
                            -Dsonar.projectKey=devsecops-project \
                            -Dsonar.projectName=DevSecOps-Project \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USR',
                    passwordVariable: 'DOCKERHUB_PSW'
                )]) {
                    sh '''
                        echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
                        docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG
                        docker push $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USR',
                        passwordVariable: 'DOCKERHUB_PSW'
                    )
                ]) {
                    sh '''
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_USER@$EC2_HOST "
                            docker pull $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG &&
                            docker stop app || true &&
                            docker rm app || true &&
                            docker run -d --name app -p 3000:3000 $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG
                        "
                    '''
                }
            }
        }
    }

    post {

        success {
            withCredentials([string(credentialsId: 'google-chat-webhook', variable: 'WEBHOOK_URL')]) {
                sh """
                curl -X POST -H 'Content-Type: application/json' \
                -d '{
                    "text": "✅ CI/CD SUCCESS 🚀\\nJob: ${JOB_NAME}\\nBuild: ${BUILD_NUMBER}\\nImage: ${IMAGE_NAME}:${IMAGE_TAG}"
                }' \
                $WEBHOOK_URL
                """
            }
        }

        failure {
            withCredentials([string(credentialsId: 'google-chat-webhook', variable: 'WEBHOOK_URL')]) {
                sh """
                curl -X POST -H 'Content-Type: application/json' \
                -d '{
                    "text": "❌ CI/CD FAILED 💥\\nJob: ${JOB_NAME}\\nBuild: ${BUILD_NUMBER}\\nCheck Jenkins logs for details"
                }' \
                $WEBHOOK_URL
                """
            }
        }

        always {
            echo "Pipeline execution completed"
        }
    }
}
