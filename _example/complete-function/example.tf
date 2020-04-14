provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true
  timeout     = 60

  filename = "./../../lambda/src"
  handler  = "index.lambda_handler"
  runtime  = "python3.8"
  iam_actions = [
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"
  ]
  names = [
    "python_layer"
  ]
  layer_filename = "./../../lambda/packages/Python3-lambda.zip"
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
  source_arns = ["arn:aws:events:eu-west-1:xxxxxxxxxxxxx:rule/rulename"]
  variables = {
    foo = "bar"
  }
}
