pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Abhishek-7373/devsecops-cicd-pipeline-app.git'
            }
        }

        stage('Build Step') {
            steps {
                sh 'echo "Build stage running..."'
                sh 'ls -l'
            }
        }
    }
}
