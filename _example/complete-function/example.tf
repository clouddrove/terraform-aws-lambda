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
  source                            = "../../"
  name                              = local.name
  environment                       = local.environment
  create_layers                     = true
  timeout                           = 60
  filename                          = "../../lambda_packages/index.zip"
  handler                           = "index.lambda_handler"
  runtime                           = "python3.8"
  compatible_architectures          = ["arm64"]
  cloudwatch_logs_retention_in_days = 7
  reserved_concurrent_executions    = 90
  iam_actions = [
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"

  ]
  names = [
    "python_layer"
  ]
  layer_filenames = ["../../lambda_packages/layer.zip"]
  compatible_runtimes = [
    ["python3.8"]
  ]

  statement_ids = [
    "AllowExecutionFromCloudWatch"
  ]
  actions = [
    "lambda:InvokeFunction"
  ]
  principals = [
    "events.amazonaws.com"
  ]
  source_arns = ["arn:aws:iam::924144197303:role/alarm-lambda-role"]
  variables = {
    foo = "bar"
  }
}
