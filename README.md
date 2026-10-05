CI/CD Pipeline using Jenkins, Docker, and Terraform

Prerequisites:
Infrastructure:
- Jenkins server set up either locally or in the cloud. In this case, my Jenkins server is set up in AWS on an EC2 instance.
- Docker installed on the Jenkins server because Jenkins is running in a Docker container. 
- Terraform is also installed and running on the server.
- Docker installed in the Jenkins container.

Jenkins Plugins:
- In addition to installing Jenkins with preset plugins, I also installed the AWS Credential, Pipeline Steps, and SSH Agent plugins.

What this pipeline does:
- Using a shared library referenced in the Jenkinsfile, a Java application is compiled into a Jar file, packaged into a Docker image, and stored in a public repository on Dockerhub.
- Once the application is stored in Dockerhub, Terraform provisions an EC2 server with a VPC, subnet, internet gateway, routing table, routes, and security groups to allow for the server to communicate over the internet.
- The server will have Docker installed on it, and after a predefined lifespan, all infrastructure will self-destruct using 'terraform destroy' to prevent unnecessary costs.