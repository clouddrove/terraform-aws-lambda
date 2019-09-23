provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "git::https://github.com/clouddrove/terraform-aws-lambda.git?ref=tags/0.12.0"

  name        = "lambda"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true

  filename           = "./../../../lambda_function_payload"
  handler            = "index.handler"
  runtime            = "nodejs8.10"
  subnet_ids         = ["subnet-xxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxx"]
  security_group_ids = ["sg-xxxxxxxxxxxxxx", "sg-xxxxxxxxxxxxxx"]
  names = [
    "lambda_layer_name"
  ]
  filenames = [
    {
      "input"  = "./../../../lambda_function_payload",
      "output" = "lambda_function_payload.zip",
    }
  ]
  compatible_runtimes = [
    ["nodejs8.10"]
  ]

  statement_ids = [
    "AllowExecutionFromSNS"
  ]
  actions = [
    "lambda:InvokeFunction"
  ]
  principals = [
    "sns.amazonaws.com"
  ]
  source_arns = [
    "arn:aws:sns:eu-west-1:xxxxxxxxxxxxxx:sns-name"
  ]
  variables = {
    foo = "bar"
  }
}