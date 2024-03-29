resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.env}-jenkins-logs"
  retention_in_days = 7
  tags              = local.tags
}