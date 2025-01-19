**DEPLOYING A WEB APPLICATION TO AMAZON ECR:**

**Prerequisites**

Jenkins installed and configured with:
JDK, Node.js, and SonarQube Scanner tools.
Credentials for AWS CLI (access_keys and secret_keys).
AWS CLI configured with proper permissions.
SonarQube Server running and configured in Jenkins.
Docker installed on the Jenkins node.

**CICD  Pipeline Stages**

Git Checkout:
Pull the source code from the Git repository.

SonarQube Analysis:
Analyze the source code for quality issues and enforce quality gates.

Quality Gate Check:
Halt the pipeline if the SonarQube quality gate fails.

NPM Install:
Install required Node.js dependencies.

Security Scan:
Run Trivy to scan the project for vulnerabilities.

Docker Build:
Build a Docker image of the application.

ECR Repository Management:
Create an Amazon ECR repository if it doesn’t exist.

ECR Login, Tagging, and Push:
Authenticate to ECR, tag the image with build numbers, and push it to ECR.

Cleanup:
Remove local Docker images to free up Jenkins workspace.

**END**
