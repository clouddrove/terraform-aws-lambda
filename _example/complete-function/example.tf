provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  environment = "test"
  label_order = ["name", "environment"]

  enabled  = true
  timeout  = 60
  filename = "../../lambda_packages"
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
  layer_filenames = ["./../../lambda/packages/Python3-lambda.zip"]
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
