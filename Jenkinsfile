pipeline{
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('tf-creds')
        AWS_SHARED_CREDENTIALS_FILE = 'credentials'

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
        stage('Validate Apply'){
           input {
                message "Do you want to apply the plan? "
                ok "Apply this Plan. "
            }
        }
        stage('Apply'){ 
            steps {
                sh 'terraform apply -auto-approve -no-color'
            }
        }
        stage('EC2 Wait'){
            steps {
                sh 'aws ec2 wait instance-status-ok --region us-west-2'
            }
        }
        stage('Ansible'){
            steps {
                ansiblePlaybook(credentialsId:'ec2-ssh-key', inventory: 'aws_hosts', playbook: 'plays/main-playbook.yml')
            }
        }
        stage('Destroy'){
            steps {
                sh 'terraform destroy -auto-approve -no-color'
            }
        }
    }
}