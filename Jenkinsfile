echo "🔥 JENKINSFILE IS EXECUTING"
pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
    }

    stages {


       stage('Detect Lambda Folders') {
    steps {
        script {

            bat 'dir'

            def output = bat(
                script: 'dir /b Jenkins-Terraform\\lambda',
                returnStdout: true
            ).trim()

            echo "RAW OUTPUT: ${output}"

            if (!output || output.contains("File Not Found")) {
                echo "No lambda folders found. Skipping pipeline."
                env.LAMBDA_DIRS = ""
            } else {
                env.LAMBDA_DIRS = output.replace("\r\n", ",")
                echo "Detected lambda folders: ${env.LAMBDA_DIRS}"
            }
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
                                if exist function.zip del function.zip
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