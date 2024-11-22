pipeline {
    agent any

    environment {
        // Jenkins credentials
        SONARQUBE_CREDS = credentials('sonarqube-credentials')  // SonarQube username & password
        DOCKER_CREDS = credentials('docker-credentials')  // DockerHub credentials
        GIT_CREDENTIALS = credentials('github-creds')  // GitHub credentials
        // vars
        APP_VERSION = '3.0.0' // define application version
        GIT_EMAIL = "ramdhaniahmedamine@gmail.com"
        GIT_BRANCH = 'chambre-management'
        SLACK_CHANNEL = '#cicd-pipeline'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo 'Cleaning workspace...'
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                echo 'Pulling changes...'
                git url: 'https://github.com/amin-rm/dorm-management-pipeline', branch: env.GIT_BRANCH
            }
        }

        stage('Unit tests with Junit') {
            steps {
                echo 'Performing unit tests...'
                dir('foyer') {
                    sh "mvn test"
                }
            }
        }

        stage('Run SonarQube Analysis') {
            steps {
                echo 'Running SonarQube Analysis...'
                dir('foyer') {
                    // sh "mvn sonar:sonar -Dsonar.login=${env.SONARQUBE_CREDS_USR} -Dsonar.password=${env.SONARQUBE_CREDS_PSW}"
                    withSonarQubeEnv('SonarQube') {
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }

        stage("Quality gate") {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                echo 'Running Trivy filesystem scan...'
                // Save the Trivy filesystem scan report to a file
                sh "trivy fs . --format table --output trivy-fs-report.txt"
            }
        }


        stage('Build with Maven') {
            steps {
                echo 'Building project...'
                dir('foyer') {
                    sh "mvn clean install -DskipTests"
                }
            }
        }


        stage('Publish to nexus') {
            steps {
                echo 'Deploying to nexus...'
                dir('foyer') {
                    sh "mvn deploy -DskipTests -Drevision=${env.APP_VERSION}"
                }
            }
        }

        stage('Build and Tag Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t foyer-app:${env.APP_VERSION} ."
            }
        }



        stage('Trivy Image Scan') {
            steps {
                echo 'Running Trivy image scan...'
                // Save the Trivy scan report to a file
                sh "trivy image foyer-app:${env.APP_VERSION} --format table --output trivy-image-report.txt"
            }
        }



        stage('Push Docker Image') {
            steps {
                echo 'Tagging and pushing Docker image to DockerHub...'
                script {
                    sh '''
                DOCKER_USER=${DOCKER_CREDS_USR}
                DOCKER_PASS=${DOCKER_CREDS_PSW}
                docker tag foyer-app:${APP_VERSION} ${DOCKER_USER}/dorm-management:${APP_VERSION}
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker push ${DOCKER_USER}/dorm-management:${APP_VERSION}
            '''
                }
            }
        }

        stage('Update helm chart') {
            steps {
                echo 'Updating helm chart...'
                dir('helm-charts/dorm-backend-app') {
                    // Update the image version in values.yaml
                    sh "sed -i 's/tag: .*/tag: ${env.APP_VERSION}/' values.yaml"

                    sh """
                        git config user.email ${GIT_EMAIL}
                        git config user.name ${GIT_CREDENTIALS_USR}
                        git add values.yaml
                        git commit -m "Update Helm chart tag to ${env.APP_VERSION}"
                        git push https://${GIT_CREDENTIALS_USR}:${GIT_CREDENTIALS_PSW}@github.com/amin-rm/dorm-management-pipeline.git HEAD:${env.GIT_BRANCH}
                    """
                }
            }
        }





    }

    post {
        always {
            echo 'Creating combined report zip...'

            // Create a directory to store all reports if needed
            sh 'mkdir -p reports'

            // Check if the JaCoCo report directory exists before copying
            script {
                if (fileExists('foyer/target/site/jacoco')) {
                    echo 'Copying JaCoCo report...'
                    dir('foyer/target/site/jacoco') {
                        sh 'cp -r * ../../../../reports/'
                    }
                } else {
                    echo 'JaCoCo report directory does not exist, skipping copy...'
                }
            }

            // Check if the Trivy image report exists
            script {
                if (fileExists('trivy-image-report.txt')) {
                    echo 'Copying Trivy image scan report...'
                    sh 'cp trivy-image-report.txt reports/'
                } else {
                    echo 'Trivy image scan report not found, skipping...'
                }
            }

            // Check if the Trivy filesystem report exists
            script {
                if (fileExists('trivy-fs-report.txt')) {
                    echo 'Copying Trivy filesystem scan report...'
                    sh 'cp trivy-fs-report.txt reports/'
                } else {
                    echo 'Trivy filesystem scan report not found, skipping...'
                }
            }

            // Zip all the reports together
            sh 'zip -r reports.zip reports/*'

            script {
                // Define the build status and path to the zip file
                def buildStatus = currentBuild.currentResult ?: 'SUCCESS'

                // Send the zip file to Slack
                slackUploadFile(
                        channel: env.SLACK_CHANNEL,
                        filePath: "reports.zip",
                        initialComment: "Build Status: ${buildStatus}. Please find the JaCoCo and Trivy reports in the attached zip file."
                )
            }
        }
    }


}
