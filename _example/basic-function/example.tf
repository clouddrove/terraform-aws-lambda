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

  filename = "./../../../lambda_function_payload"
  handler  = "index.handler"
  runtime  = "nodejs8.10"
}
