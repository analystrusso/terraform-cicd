#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
  [$class: 'GitSCMSource',
  remote: 'https://github.com/analystrusso/jenkins-shared-library.git',
  credentialsId: 'gitlab-credentials'
  ]
)

pipeline {   
  agent any
  tools {
    maven 'maven-3.9'
  }
  environment {
    IMAGE_NAME = 'analystrusso/twn-bootcamp-repo:java-maven-2.0'
  }
  stages {
    stage("build app") {
      steps {
        script {
          echo 'building application jar...'
          buildJar()
        }
      }
    }
    stage("build image") {
      steps {
        script {
          echo 'building docker image...'
          buildImage(env.IMAGE_NAME)
          dockerLogin()
          dockerPush(env.IMAGE_NAME)
        }
      }
    }
    stage("provision server") {
      environment {
        TF_VAR_env_prefix = 'test'
      }
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-access-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretkeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]])
        script {
          dir('terraform') {
            sh "terraform init"
            sh "terraform apply --auto-approve"
            env.EC2_PUBLIC_IP = sh(
              script: "terraform output -raw ec2_public_ip",
              returnStdout: true
            ).trim()
          }
        }
      }
    }
    stage("deploy") {
      environment {
        DOCKER_CREDS = credentials('docker-hub-repo')
      }
      steps {
        script {
          echo "waiting for EC2 server to initialize"
          sleep(time: 90, unit: "SECONDS")

          echo 'deploying docker image to EC2...'
          
          def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
          def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

          sshagent(['server-ssh-key']) {
            sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
            sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
            sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
          }
        }
      }
    }          
    stage("teardown") {
      environment {
        TF_VAR_env_prefix = 'test'
      }
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-access-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretkeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]])
        script {
          echo "destroying provisioned infrastructure"
          sleep(time: 10, unit: "MINUTES")
          dir('terraform') {
            sh "terraform destroy --auto-approve" 
          }
        }
      }
    }     
  }
}
