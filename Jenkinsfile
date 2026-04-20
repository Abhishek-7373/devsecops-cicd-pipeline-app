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
                    script {
                        def scannerHome = tool 'sonar-scanner'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }
}
