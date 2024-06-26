resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.prefix}-jenkins-logs"
  kms_key_id = aws_kms_key.cloudwatch.arn
  retention_in_days = 7
  tags              = local.tags
}


## KMS ## 

resource "aws_kms_key" "cloudwatch" {
  description             = "CMK for the Snowplow S3 Bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  is_enabled              = true
  policy                  = data.aws_iam_policy_document.cloudwatch_kms_policy.json

  tags = local.tags
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/${local.prefix}-jenkins-cloudwatch-log-group"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

data "aws_iam_policy_document" "cloudwatch_kms_policy" {
  statement {
    sid    = "KMSDecrypt"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-jenkins-ec2-role",
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMS"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }
    actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AdminAccessToKMS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kms_decrypt_cloudwatch" {
  name        = "${local.prefix}-jenkins-kms-decrypt-cloudwatch-policy"
  path        = "/"
  description = "This Policy gives access to decrypt jenkins cloudwatch KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteToBucket"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.cloudwatch.arn
      }
    ]
  })

  tags = local.tags
}