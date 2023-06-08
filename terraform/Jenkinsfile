pipeline {
    agent {
        label "agent"; 
    }
    environment {
        GOOGLE_CREDENTIALS = credentials('gcp-terraform-json')
        workdir = 'terraform'
    }
    stages {
        stage('Terraform init') {
            steps {
                dir(workdir) {
                    sh 'terraform init'              
                }
            }
        }
        
        stage('Terraform plan') {
            steps {
                dir(workdir) {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform apply') {         
            steps {
                dir(workdir) {
                    sh 'terraform apply --auto-approve'
                }
            }
        }
    }
}
