resource "aws_iam_instance_profile" "this" {
  name = "${local.prefix}-jenkins-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name        = "${local.prefix}-jenkins-ec2-role"
  description = "Allows the Jenkins service to"
  tags        = local.tags

  assume_role_policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": [ "ec2.amazonaws.com" ]},
      "Action": [ "sts:AssumeRole" ]
    }
  ]
}
EOF

}

resource "aws_iam_policy" "this" {
  name = "${local.prefix}-jenkins-ec2-policy"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this.name}:*"
      ]
    },
    {
      "Sid": "ECRToken",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": ["*"]
    },
    {
      "Sid": "ECRUploadImage",
      "Effect": "Allow",
      "Action": [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${local.prefix}-dbt-docs"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


## IAM POLCIY ATTACHMENTS ##

# Policy found at patrick-cloud-jenkins/tf/iam.tf:aws_iam_policy.kms_decrypt_cloudwatch
resource "aws_iam_role_policy_attachment" "kms_decrypt_cloudwatch" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.kms_decrypt_cloudwatch.arn
}

# Enable SSM connection so it easy to connect to ec2 in private subnet for deubugging
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}