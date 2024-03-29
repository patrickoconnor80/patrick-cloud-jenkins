#!/bin/bash

# sudo yum update –y
# sudo wget -O /etc/yum.repos.d/jenkins.repo \
#     https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# sudo yum upgrade
# sudo dnf install java-17-amazon-corretto -y
# sudo yum install jenkins -y
# sudo systemctl enable jenkins
# sudo systemctl start jenkins





echo "Install Java (Dependency for Jenkins)"
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
echo "Java version: $(java -version)"

echo "Install Jenkins and start service"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins=2.401.1 -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
echo "Jenkins version: $(jenkins --version)"

echo "Install Docker"
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

echo "Give Jenkins User access to Docker, then restart"
sudo usermod -a -G docker jenkins
sudo systemctl restart jenkins

# echo "Run SonarQube"
# docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# echo "Install Trivy"
# sudo apt-get install wget apt-transport-https gnupg lsb-release
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
# echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
# sudo apt-get update -y
# sudo apt-get install trivy -y

# Install Nginx
sudo apt update
sudo apt install nginx -y

mkdir -p /var/log/nginx/
mkdir -p /usr/share/nginx/html

# Create jenkins_nginx_index.html file from local directory
sudo cat > /usr/share/nginx/html/jenkins_nginx_index.html <<EOF
${jenkins-nginx-index}
EOF

# Create reverse proxy config file from local directory
sudo cat > /etc/nginx/sites-available/reverse-proxy.conf <<EOF
${reverse-proxy-conf}
EOF

# Unlink default config and link reverse-proxy as default config 
sudo unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

# Create self-signed certifcates
cd /home/ubuntu
mkdir .ssl
cd .ssl
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj \
    "/C=US/ST=MA/L=Boston/O=patrick-cloud.com/OU=Self/CN=jenkins.patrick-cloud.com"

# Start jenkins
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx

## Not sure if this is needed
## sudo nano /etc/default/jenkins
## """
## JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1"
##"""
## sudo systemctl restart jenkins