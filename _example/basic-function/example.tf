provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "./../../"

  name        = "lambda"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true

  filename = "./../../../lambda_function_payload"
  handler  = "index.handler"
  runtime  = "nodejs8.10"
}
