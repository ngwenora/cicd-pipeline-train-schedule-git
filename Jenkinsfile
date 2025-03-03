pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = "ngwe093/pocpub"
                    app = docker.build(imageName)
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    def imageName = "ngwe093/pocpub"
                    sh 'echo "Attempting explicit docker login..."'
                    withCredentials([usernamePassword(credentialsId: 'docker_login', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"'
                    }
                    sh 'echo "Docker login complete. Attempting to push..."'

                    sh "docker tag ${imageName} docker.io/${imageName}:${env.BUILD_NUMBER}"
                    sh "docker images"
                    sh "docker push docker.io/${imageName}:${env.BUILD_NUMBER}"
                    sh "docker push docker.io/${imageName}:latest"
                }
            }
        }
        stage('Deploy to Staging') {
            steps {
                script {
                    def imageName = "ngwe093/pocpub:${env.BUILD_NUMBER}"
                    withKubeConfig(credentialsId: 'eks-login', namespace: 'staging') {
                        sh "kubectl set image deployment/poc-staging poc-staging=${imageName}"
                        sh "kubectl rollout restart deployment/your-deployment-name"
                    }
                }
            }
        }
        stage('Approval to Deploy to Production') {
            steps {
                input message: 'Approve deployment to production?'
            }
        }
        stage('Deploy to Production') {
            when {
                expression {
                    currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    def imageName = "ngwe093/pocpub:${env.BUILD_NUMBER}"
                    withKubeConfig(credentialsId: 'eks-login', namespace: 'production') {
                        sh "kubectl set image deployment/poc-production poc-production=${imageName}"
                        sh "kubectl rollout restart deployment/your-deployment-name"
                    }
                }
            }
        }
    }
}
