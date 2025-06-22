pipeline {
    agent {
        docker{
            image 'awajid3/npmnodegit:1.0.0'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock  -p 18000:18000'
        }
    }
    stages {
        stage('check prerequisites') {
            steps {
                sh '''
                npm -v
                node -v
                '''
            }
        }
        stage('checkout the project code') {
            when {expression { 2==2 }}
                steps {
                    git branch: 'window_access', changelog: false, poll: false, url: 'https://github.com/Jack-shah/nodejs_project.git'
                    sh '''
                    pwd
                    ls -a
                    '''
            }
        }
    stage('install dependecies') {
            when {expression { 2==2 }}
              steps {
                    sh '''
                    pwd
                    cd nodejs-application
                    ls -a
                    npm install
                '''
            }
        }
    stage('Build') {
        when {expression { 2==2 }}
            steps {
                sh '''
                 pwd
                 cd nodejs-application
                 npm run build        
                 '''
            }
        }
        stage('Run the application') {
        when {expression { 2==2 }}
            steps {
                sh '''
                 pwd
                 cd nodejs-application
                 node dist/src/index.js
                 '''
            }
        }
    }
}
