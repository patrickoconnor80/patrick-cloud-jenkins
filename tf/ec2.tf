resource "aws_instance" "jenkins" {
  ami = "ami-0e21465cede02fd1e"
  instance_type          = "t2.large"
  subnet_id              = local.private_subnet_ids[0]
  vpc_security_group_ids = [data.aws_security_group.jenkins_sg.id]
  iam_instance_profile = aws_iam_instance_profile.this.id
  user_data              = local.user_data
  key_name               = "patrick-cloud-jenkins"
  root_block_device {
    volume_size = 30
    delete_on_termination = false
    tags = merge(local.tags, {Name="${local.prefix}-jenkins-root-volume"})
  }
  tags                   = merge(local.tags, {Name="${local.prefix}-jenkins-ec2"})
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = data.aws_alb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins.id
}

## ALARMS ##

resource "aws_cloudwatch_log_metric_filter" "jenkins" {
  name           = "${local.prefix}-jenkins-ec2-error-metric-filter"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.this.name
  metric_transformation {
    name      = "${local.prefix}-jenkins-ec2-error"
    namespace = "JenkinsError"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "jenkins" {
  alarm_name          = "${local.prefix}-jenkins-error-alarm"
  alarm_description   = "Send email for any errors with Jenkins"
  metric_name         = "${local.prefix}-jenkins-error"
  namespace           = "JenkinsError"
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "300"
  alarm_actions       = [data.aws_sns_topic.email.arn]
  tags                = local.tags
}