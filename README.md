
# Dorm Management Application DevOps Pipeline

This repository contains a CI/CD for a dorm management application built with **Spring Boot** and **MySQL**.

## Key Features

- **CI/CD Automation with Jenkins**: Automates code building, testing, and deployment using Jenkins pipelines.
- **Unit Testing with JUnit & H2 Database**: Ensures application reliability through automated testing.
- **Static Code Analysis with SonarQube**: Improves code quality, checks for security vulnerabilities, and ensures compliance.
- **Containerization with Docker**: Creates Docker images of Spring Boot services and pushes them to **Nexus** for artifact management.
- **Real-time Notifications via Slack**: Sends notifications for build statuses and detailed code coverage reports (JaCoCo).
- **Optimized Resource Management**: Uses Helm charts for scalable Kubernetes deployments with efficient resource allocation.
- **Vulnerability Scanning with Trivy**: Integrates Trivy for comprehensive filesystem and Docker image vulnerability scanning, ensuring robust security compliance throughout the development lifecycle.

## Jenkinsfile Overview

The **Jenkinsfile** included in this repository is designed for general-purpose use with **Java** applications built using **Maven archetypes**. You can either use the provided **Spring Boot project ('foyer')** or integrate your own project.

### Prerequisites

To use the Jenkinsfile, ensure that the following tools are installed on your system:

- **Maven**
- **SonarQube**
- **JDK 17**
- **Sonatype Nexus Repository**
- **Slack Plugin (for Jenkins)**
- **Docker**
- **Trivy**

For a simpler setup of SonarQube and Nexus, you can use their Docker images and run them as containers:

```bash
docker pull sonatype/nexus3
docker pull sonarqube
```

### Slack Integration
To integrate Slack with Jenkins for real-time notifications, refer to this guide: [Slack Plugin for Jenkins](https://plugins.jenkins.io/slack/)


### Jenkinsfile Configuration
The Jenkinsfile uses environment variables for sensitive information (such as SonarQube, DockerHub, and Nexus credentials). You'll need to configure these secrets in your Jenkins instance. If you're using a private GitHub or GitLab repository, add your repository secrets as well.

### Customization
You can customize the Jenkinsfile to suit your specific project needs, such as adjusting the test and build stages or modifying notification settings.

## Deployment Options

### 1. Deploying on Kubernetes (with Helm)

- Ensure Helm is installed on your system (refer to [Installing Helm](https://helm.sh/docs/intro/install/)).
- Use the Helm chart located in helm-charts/dorm-backend-app. This chart includes MySQL as a dependency, preconfigured with a persistent volume and claim.
- Modify environment variables like resource limits, replicas, and database settings to fit your requirements.
- Important: For security, use Kubernetes secrets to handle sensitive data like passwords. To create a secret, run:

```bash
kubectl create secret generic my-secret --from-literal=password=my-password
```

### 2. Running on a Local Machine

- Ensure you have a compatible JRE and a running MySQL database.
- Download the JAR artifact from your Nexus repository and run the following command:

```bash
java -jar <artifact-name>.jar
```

### 3. Running with Docker Compose

- Use the provided docker-compose.yaml file to run the application and MySQL in Docker containers. Simply modify the necessary environment variables, and then start the containers with:

```bash
docker-compose up -d
```
- This will spin up both the backend application and the MySQL database.
- Customize environment variables and database credentials accordingly.

## Conclustion

This project demonstrates a complete CI/CD pipeline using modern DevOps tools to streamline the development and deployment of a Spring Boot application. Feel free to modify the configurations and settings to suit your project's needs.
