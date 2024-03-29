data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "this" {
  ami = "ami-0e21465cede02fd1e"
  #ami                    = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 AMI
  #ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  subnet_id              = local.public_subnet_ids[0]
  vpc_security_group_ids = [data.aws_security_group.jenkins_sg.id]
  user_data              = local.user_data
  key_name               = "patrick-cloud-jenkins"
  root_block_device {
    volume_size = 30
    delete_on_termination = false
    tags = merge(local.tags, {Name="${local.prefix}-jenkins-root-volume"})
  }
  tags                   = merge(local.tags, {Name="${local.prefix}-jenkins-ec2"})
}