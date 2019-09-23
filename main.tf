## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git"

  name        = var.name
  application = var.application
  environment = var.environment
  label_order = var.label_order
}

# Module      : Iam role
# Description : Terraform module to create Iam role resource on AWS for lambda.
resource "aws_iam_role" "default" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Module      : Iam policy
# Description : Terraform module to create Iam policy resource on AWS for lambda.
resource "aws_iam_policy" "default" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSecurityGroups",
        "sqs:SendMessage",
        "sns:Publish"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Module      : Iam Role Policy Attachment
# Description : Terraform module to attach Iam policy with role resource on AWS for lambda.
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

# Module      : Archive file
# Description : Terraform module to zip a directory.
data "archive_file" "lambda_zip" {
    count       = length(var.filenames) > 0 ? length(var.filenames) : 0
    type        = "zip"
    source_dir  = element(var.filenames, count.index)["input"]
    output_path = element(var.filenames, count.index)["output"]
}

# Module      : Lambda layers
# Description : Terraform module to create Lambda layers resource on AWS.
resource "aws_lambda_layer_version" "default" {
  count               = length(var.names) > 0 ? length(var.names) : 0
  filename            = length(var.filenames) > 0 ? element(var.filenames, count.index)["output"] : null
  s3_bucket           = length(var.s3_buckets) > 0 ? element(var.s3_buckets, count.index) : null
  s3_key              = length(var.s3_keies) > 0 ? element(var.s3_keies, count.index) : null
  s3_object_version   = length(var.s3_object_versions) > 0 ? element(var.s3_object_versions, count.index) : null
  layer_name          = element(var.names, count.index)
  compatible_runtimes = element(var.compatible_runtimes, count.index)
  description         = length(var.descriptions) > 0 ? element(var.descriptions, count.index) : ""
  license_info        = length(var.license_infos) > 0 ? element(var.license_infos, count.index) : ""
  source_code_hash    = length(var.filenames) > 0 ? filesha256(element(var.filenames, count.index)["output"]) : ""
}

# Module      : Archive file
# Description : Terraform module to zip a directory.
data "archive_file" "default" {
    count       = var.filename != null ? 1 : 0
    type        = "zip"
    source_dir  = var.filename
    output_path = "lambda.zip"
}

# Module      : Lambda function
# Description : Terraform module to create Lambda function resource on AWS.
resource "aws_lambda_function" "default" {
  count = var.enabled ? 1 : 0

  function_name                  = module.labels.id
  description                    = var.description
  role                           = aws_iam_role.default.arn
  filename                       = var.filename != null ? "lambda.zip" : null
  s3_bucket                      = var.s3_bucket
  s3_key                         = var.s3_key
  s3_object_version              = var.s3_object_version
  handler                        = var.handler
  layers                         = aws_lambda_layer_version.default.*.arn
  memory_size                    = var.memory_size
  runtime                        = var.runtime
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  kms_key_arn                    = var.kms_key_arn
  source_code_hash               = var.filename != null ? filesha256("lambda.zip") : ""
  tags                           = module.labels.tags
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  environment {
   variables = var.variables
  }
  depends_on = ["aws_iam_role_policy_attachment.default"]
}

# Module      : Lambda Permission
# Description : Terraform module to create Lambda permission resource on AWS to create
#               trigger for function.
resource "aws_lambda_permission" "default" {
  count              = length(var.actions) > 0 ? length(var.actions) : 0
  statement_id       = length(var.statement_ids) > 0 ? element(var.statement_ids, count.index) : ""
  event_source_token = length(var.event_source_tokens) > 0 ? element(var.event_source_tokens, count.index) : null
  action             = element(var.actions, count.index)
  function_name      = aws_lambda_function.default.*.function_name[0]
  principal          = element(var.principals, count.index)
  qualifier          = length(var.qualifiers) > 0 ? element(var.qualifiers, count.index) : null
  source_account     = length(var.source_accounts) > 0 ? element(var.source_accounts, count.index) : null
  source_arn         = length(var.source_arns) > 0 ? element(var.source_arns, count.index) : ""
}