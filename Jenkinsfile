pipeline {
    agent any

    tools {
        jdk 'JDK'
        nodeJS 'NodeJS'
    }
    parameters {
        string(name: 'ECR_REPO_NAME',defaultValue: 'web-app', description: 'Enter your ECR repo name: ')
        string(name: 'AWS_ACCOUNT_ID',defaultValue: 'web-app', description: 'Enter your ECR your AWS_ACCOUNT_ID: ')
    
    }

    environment {
        SCANNER_HOME = tool 'SonarQube Scanner'
    }
    stages {
        stage('Git Checkout: 1') {
            steps {
                git branch: 'main', url: 'https://github.com/Pepuhove/simple-nodejs-app..git'
            }
        }
        stage('SonarQube Analysis: 2') {
            steps {
                withSonarQubeEnv ('sonar-server'){
                   $SCANNER_HOME/bin/sonar-scanner \
                   -Dsonar.projectName=simple-web-app \
                   -Dsonar.projectKey=simple-web-app
                }
            }
        }
        stage('Quality Gates: 3') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }
        stage('NPM Install: 4') {
            steps {
                sh 'npm install'
            }
        }
        stage('Trivy Scann: 5') {
            steps {
                sh 'trivy fs . >trivy-scan.txt'
            }
        }
        stage('Docker: 6') {
            steps {
                sh 'docker build -t ${params.ECR_REPO_NAME} .'
            }
        }
        stage('Create ECR repository: 7') {
            steps {
                withCredentials([string(credentialsId: 'access_keys', variable: 'AWS_ACCESS_KEYS'), string(credentialsId: 'secret_keys', variable: 'AWS_SECRET_KEYS')]) {
                   sh """
                   aws configure set aws_access_key_id $AWS_ACCESS_KEYS
                   aws configure set aws_secret_access_key $AWS_SECRET_KEYS
                   aws ecr describe-repositories --repository-names ${params.ECR_REPO_NAME} --region us-east-1 || \
                   aws ecr create-repository --repository-name ${params.ECR_REPO_NAME} --region us-east-1
                   """
                }
            }
        }
         stage('Login to ECR & tag image: 8') {
            steps {
                withCredentials([string(credentialsId: 'access_keys', variable: 'AWS_ACCESS_KEYS'), string(credentialsId: 'secret_keys', variable: 'AWS_SECRET_KEYS')]) {
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
        stage('Clean_up Images from Jenkins: 10') {
           steps {
              sh """
                 docker rm ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:$BUILD_NUMBER
                 docker rm ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                 """
            }
        }
    }
}
