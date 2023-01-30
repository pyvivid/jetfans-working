pipeline{
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('tf-creds')

    }
    stages{
        stage('init'){
            steps {
                sh 'ls'
                sh 'terraform init -no-color'
            }
        }
        stage('plan'){
            steps {
                sh 'terraform plan -no-color'
            }
        }
    }
}