pipeline {
    agent any

    stages {

        stage('Build Step') {
            steps {
                sh 'echo "Build stage running..."'
                sh 'ls -l'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh 'sonar-scanner'
                }
            }
        }
    }
}
