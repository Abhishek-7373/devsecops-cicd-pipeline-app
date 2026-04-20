pipeline {
    agent any

    tools {
        sonarQube 'sonar-scanner'
    }

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
