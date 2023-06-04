pipeline {
    agent {
        label "agent"; 
    }
    environment {
        agent_credentials = credentials('jenkins-agent')
    }
    stages {
        stage('Preparando el entorno') {
            steps {
                sh 'whoami'
                sh 'echo POR FAVOR !!!!!! fijaos en este dato'
                sh 'hostname'
                sh 'python3 -m pip install -r requirements.txt'
            }
        }
        
        stage('Calidad de código') {
            steps {
                sh 'whoami'
                sh 'hostname'
                sh 'python3 -m pylint app.py'
            }
        }

        stage('Tests') {         
            steps {
                sh 'whoami'
                sh 'hostname'
                sh 'python3 -m pytest'
            }
        }

        stage('Construcción del artefacto') {
            steps {
                sh 'whoami'
                sh 'hostname'
                sh 'docker version'
                sh 'docker build https://github.com/sergioaten/alisson-gcp.git#main -t us-central1-docker.pkg.dev/jenkins-project-388812/jenkins-repo/pythonapp:${GIT_COMMIT}'
            }
        }

        stage('Subir artefacto a repositorio docker') {
            steps {
                sh 'gcloud auth activate-service-account --key-file=$agent_credentials'
                sh 'docker push us-central1-docker.pkg.dev/jenkins-project-388812/jenkins-repo/pythonapp:${GIT_COMMIT}'
            }
        }

        // stage('Despliegue') {
        //     steps {
        //         sh 'whoami'
        //         sh ' echo si el dato anterior es root ... NOS HEMOS VUELTO LOCOS Y VAMOS A MORIR TODOS!!!!!!'
        //         sh 'hostname'
        //         sh 'docker run --name srgapp -d -p 5000:5000 srgjenkins:${GIT_COMMIT}'
        //     }
        // }
    }
}
