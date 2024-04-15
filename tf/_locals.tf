locals {
  prefix           = "patrick-cloud-${var.env}"
  public_subnet_ids = [for subnet in data.aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  ssh_ip_allowlist = [format("%s/%s", data.external.whatismyip.result["internet_ip"], 32)]
    tags = {
        env        = var.env
        project       = "patrick-cloud"
        deployment = "terraform"
        repo = "https://github.com/patrickoconnor80/patrick-cloud-jenkins/tree/main/tf"
    }
  user_data = templatefile("../bin/user-data.sh", {
    reverse-proxy-conf = file("../cfg/reverse-proxy.conf")
    jenkins-nginx-index = file("../cfg/jenkins_nginx_index.html")
  })
}