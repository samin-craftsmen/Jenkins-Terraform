pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Lambda Folders') {
            steps {
                script {
                    def lambdaDirs = []
                    def lambdaRoot = "${env.WORKSPACE}/lambda"
                    def rootDir = new File(lambdaRoot)
                    if (rootDir.exists()) {
                        rootDir.eachDir { dir ->
                            lambdaDirs.add(dir.name)
                        }
                    }
                    if (lambdaDirs.isEmpty()) {
                        echo "No lambda folders found under lambda/. Skipping build."
                    }
                    env.LAMBDA_DIRS = lambdaDirs.join(',')
                }
            }
        }

        stage('Build & Zip Lambdas') {
            when {
                expression { env.LAMBDA_DIRS?.trim() }
            }
            steps {
                script {
                    def dirs = env.LAMBDA_DIRS.split(',')
                    for (d in dirs) {
                        dir("lambda/${d}") {
                            echo "Building lambda: ${d}"
                            bat """
                                set GOOS=linux
                                set GOARCH=amd64
                                set CGO_ENABLED=0
                                go build -tags lambda.norpc -o bootstrap .
                            """
                            bat """
                                tar -a -cf function.zip bootstrap
                            """
                            bat "del bootstrap"
                        }
                    }
                }
            }
        }

        stage('Terraform Init') {
            when {
                expression { env.LAMBDA_DIRS?.trim() }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred'
                ]]) {
                    dir('terraform') {
                        bat 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { env.LAMBDA_DIRS?.trim() }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred'
                ]]) {
                    dir('terraform') {
                        bat 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.LAMBDA_DIRS?.trim() }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred'
                ]]) {
                    dir('terraform') {
                        bat 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check the logs above.'
        }
    }
}
