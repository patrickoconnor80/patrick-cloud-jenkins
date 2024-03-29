resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  description = "Allow ssh from local"
  from_port   = 22
  to_port     = 22 
  protocol    = "tcp"
  cidr_blocks = local.ssh_ip_allowlist
  security_group_id = data.aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  description = "Allow HTTPS Traffic from the ALB"
  from_port   = 443
  to_port     = 443 
  protocol    = "tcp"
  source_security_group_id = data.aws_security_group.alb_sg.id
  security_group_id = data.aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  description = "Allow all outbound requests"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.jenkins_sg.id
}