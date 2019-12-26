provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "git::https://github.com/clouddrove/terraform-aws-lambda.git?ref=tags/0.12.2"

  name        = "lambda"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true

  filename = "./../../../lambda_packages"
  handler  = "index.lambda_handler"
  runtime  = "python3.7"
  variables = {
    foo = "bar"
  }
}
