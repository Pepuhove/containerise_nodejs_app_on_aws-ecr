pipeline {
    agent any

    tools {
        jdk 'JDK'       // Ensure you configure JDK in Jenkins with this name
        nodejs 'NodeJS' // Ensure you configure NodeJS in Jenkins with this name
    }

    parameters {
        string(name: 'ECR_REPO_NAME', defaultValue: 'web-app', description: 'Enter your ECR repo name:')
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '123456789012', description: 'Enter your AWS Account ID:')
    }

    environment {
        SCANNER_HOME = tool 'SonarQube Scanner' // Ensure this matches the configured name of the SonarQube scanner
    }

    stages {
        stage('Git Checkout: 1') {
            steps {
                git branch: 'main', url: 'https://github.com/Pepuhove/simple-nodejs-app.git'
            }
        }

        stage('SonarQube Analysis: 2') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectName=simple-web-app \
                    -Dsonar.projectKey=simple-web-app
                    -X
                    """
                }
            }
        }

        stage('Quality Gates: 3') {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }

        stage('NPM Install: 4') {
            steps {
                sh 'npm install'
            }
        }

        stage('Trivy Scan: 5') {
            steps {
                sh 'trivy fs . > trivy-scan.txt'
            }
        }

        stage('Docker Build: 6') {
            steps {
                sh 'docker build -t ${params.ECR_REPO_NAME} .'
            }
        }

        stage('Create ECR Repository: 7') {
            steps {
                withCredentials([
                    string(credentialsId: 'access_keys', variable: 'AWS_ACCESS_KEYS'),
                    string(credentialsId: 'secret_keys', variable: 'AWS_SECRET_KEYS')
                ]) {
                    sh """
                    aws configure set aws_access_key_id $AWS_ACCESS_KEYS
                    aws configure set aws_secret_access_key $AWS_SECRET_KEYS
                    aws ecr describe-repositories --repository-names ${params.ECR_REPO_NAME} --region us-east-1 || \
                    aws ecr create-repository --repository-name ${params.ECR_REPO_NAME} --region us-east-1
                    """
                }
            }
        }

        stage('Login to ECR & Tag and Push Image: 8') {
            steps {
                withCredentials([
                    string(credentialsId: 'access_keys', variable: 'AWS_ACCESS_KEYS'),
                    string(credentialsId: 'secret_keys', variable: 'AWS_SECRET_KEYS')
                ]) {
                    sh """
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
                    docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                    docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

        stage('Clean up Images from Jenkins: 9') {
            steps {
                sh """
                docker rmi ${params.ECR_REPO_NAME}
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                """
            }
        }
    }
}
