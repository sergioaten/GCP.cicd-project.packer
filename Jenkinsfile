pipeline {
    agent {
        label "agent"; 
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

        stage('construcción del artefacto') {
            steps {
                sh 'whoami'
                sh 'hostname'
                sh 'docker version'
                sh 'docker build https://github.com/sergioaten/alisson-gcp.git#main -t srgjenkins:${GIT_COMMIT}'
            }
        }

        stage('Despliegue') {
            steps {
                sh 'whoami'
                sh ' echo si el dato anterior es root ... NOS HEMOS VUELTO LOCOS Y VAMOS A MORIR TODOS!!!!!!'
                sh 'hostname'
                sh 'docker run --name srgapp -tdi -p 4000:5000 srgjenkins:${GIT_COMMIT}'
            }
        }
    }
}
