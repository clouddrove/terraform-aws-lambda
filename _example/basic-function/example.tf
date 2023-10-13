provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  environment = "test"
  label_order = ["name", "environment"]

  enable                     = true
  filename                   = "../../lambda_packages"
  handler                    = "index.lambda_handler"
  runtime                    = "python3.7"
  variables = {
    foo = "bar"
  }
}
