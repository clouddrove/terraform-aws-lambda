provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  environment = "test"
  label_order = ["name", "environment"]

  enabled                    = true
  enabled_cloudwatch_logging = true
  filename                   = "../../lambda_packages"
  handler                    = "index.lambda_handler"
  runtime                    = "python3.7"
  variables = {
    foo = "bar"
  }
}
