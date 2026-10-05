#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
  [$class: 'GitSCMSource',
   remote: 'https://github.com/analystrusso/jenkins-shared-library.git',
   credentialsId: 'gitlab-credentials'
  ]
)

// Fix 1: parameter is secretKeyVariable (capital K), not secretkeyVariable.
// Defined once so provision and teardown can't drift apart.
def awsCreds = [[
  $class: 'AmazonWebServicesCredentialsBinding',
  credentialsId: 'aws-access-creds',
  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
]]

pipeline {
  agent any
  tools {
    maven 'maven-3.9'
  }
  environment {
    IMAGE_NAME = 'analystrusso/twn-bootcamp-repo:java-maven-2.0'
    // Pipeline-level so the post-always destroy sees the same variable as apply.
    TF_VAR_env_prefix = 'test'
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
          dockerLogin()   // uses 'docker-hub-repo' inside the shared library
          dockerPush(env.IMAGE_NAME)
        }
      }
    }

    stage("provision server") {
      steps {
        // Fix 2: the work now lives INSIDE the withCredentials body.
        withCredentials(awsCreds + [string(credentialsId: 'ssh-public-key', variable: 'TF_VAR_ssh_public_key')]) {
          script {
            // Set before apply so a partially failed apply still gets destroyed.
            env.TF_PROVISIONED = 'true'
            dir('terraform') {
              sh 'terraform init -input=false'
              sh 'terraform apply -input=false --auto-approve'
              env.EC2_PUBLIC_IP = sh(
                script: 'terraform output -raw ec2_public_ip',
                returnStdout: true
              ).trim()
            }
          }
        }
      }
    }

    stage("deploy") {
      environment {
        DOCKER_CREDS = credentials('dockerhub-creds')
      }
      steps {
        script {
          echo "waiting for EC2 server to initialize"
          sleep(time: 90, unit: "SECONDS")

          echo 'deploying docker image to EC2...'
          sshagent(['myapp-keypair']) {
            // Fix 4: single-quoted so the *shell* expands variables, not Groovy.
            // The password goes over ssh stdin and never appears in argv/ps.
            // accept-new records the host key on first contact and refuses a
            // changed key; it does not protect the very first connection.
            sh '''
              ssh-add -l
              ssh -vvv -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} true
              scp -o StrictHostKeyChecking=no server-cmds.sh docker-compose.yaml \
                "ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user/"
              printf '%s' "$DOCKER_CREDS_PSW" | ssh -o StrictHostKeyChecking=accept-new \
                "ec2-user@${EC2_PUBLIC_IP}" \
                "bash ./server-cmds.sh '$IMAGE_NAME' '$DOCKER_CREDS_USR'"
            '''
          }
        }
      }
    }

    stage("keep alive") {
      steps {
        echo "infrastructure stays up for 10 minutes, then post/always destroys it"
        sleep(time: 10, unit: "MINUTES")
      }
    }
  }

  // Fix 3: runs on success, failure, and abort, so a failed deploy
  // can no longer leave the EC2 instance running.
  post {
    always {
      script {
        if (env.TF_PROVISIONED == 'true') {
          echo "destroying provisioned infrastructure"
          withCredentials(awsCreds + [string(credentialsId: 'ssh-public-key', variable: 'TF_VAR_ssh_public_key')]) {
            dir('terraform') {
              sh 'terraform init -input=false'
              sh 'terraform destroy -input=false --auto-approve'
            }
          }
        }
      }
    }
  }
}