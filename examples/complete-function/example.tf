provider "aws" {
  region = "us-east-1"
}

locals {
  name        = "lambda"
  environment = "test"
}

##-----------------------------------------------------------------------------
## complete lambda Module Call.
##-----------------------------------------------------------------------------
module "lambda" {
  source = "../../"

  name        = local.name
  environment = local.environment

  filename                          = "../../lambda_packages/index.zip" # -- The content of index.py should be present in zip format
  handler                           = "index.lambda_handler"
  runtime                           = "python3.8"
  compatible_architectures          = ["arm64"]
  timeout                           = 60
  reserved_concurrent_executions    = 90
  cloudwatch_logs_retention_in_days = 7

  # -- ARNs of Triggers
  source_arns = [""]

  # -- Lambda-Function IAMRole permission
  iam_actions = [
    "s3:PutObject",
    "s3:ListBucket",
    "s3:GetObject",
    "s3:PutObjectAcl",
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface",
    "ec2:AssignPrivateIpAddresses",
    "ec2:UnassignPrivateIpAddresses"
  ]

  # -- Lambda Layer
  create_layers   = true
  layer_names     = ["python_layer"]
  layer_filenames = ["../../lambda_packages/layer.zip"] # -- The content of layer.py should be present in zip format
  compatible_runtimes = [
    ["python3.8", "python3.10"],
  ]

  # -- Resource-based policy statements
  statement_ids = ["AllowExecutionFromCloudWatch"]
  actions       = ["lambda:InvokeFunction"]
  principals    = ["events.amazonaws.com"]

  # -- Environment Variables
  variables = {
    foo = "bar"
  }
}
