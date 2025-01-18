pipeline {
    agent any

    tools {
        jdk 'JDK'
        nodejs 'NodeJS'
    }

    parameters {
        string(name: 'ECR_REPO_NAME', defaultValue: 'web-app', description: 'Enter your ECR repo name:')
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '123456789012', description: 'Enter your AWS Account ID:')
    }

    environment {
        SCANNER_HOME = tool 'SonarQube Scanner'
        AWS_REGION = 'us-east-1'
        IMAGE_NAME = "${params.ECR_REPO_NAME}"
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
                    -Dsonar.projectKey=simple-web-app \
                    -X
                    """
                }
            }
        }

        stage('Quality Gates: 3') {
            steps {
                waitForQualityGate abortPipeline: true, pollingIntervalInSeconds: 30
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
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Create ECR Repository: 7') {
            steps {
                withEnv(['AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEYS', 'AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEYS']) {
                    sh """
                    aws ecr describe-repositories --repository-names ${IMAGE_NAME} --region ${AWS_REGION} || \
                    aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${AWS_REGION}
                    """
                }
            }
        }

        stage('Login to ECR & Tag and Push Image: 8') {
            steps {
                withEnv(['AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEYS', 'AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEYS']) {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    docker tag ${IMAGE_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:$BUILD_NUMBER
                    docker tag ${IMAGE_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:$BUILD_NUMBER
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Clean up Images from Jenkins: 9') {
            steps {
                sh """
                docker rmi ${IMAGE_NAME}
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:$BUILD_NUMBER
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
                """
            }
        }
    }
}
