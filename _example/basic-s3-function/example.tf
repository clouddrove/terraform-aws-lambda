provider "aws" {
  region = "eu-west-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  repository  = "https://registry.terraform.io/modules/clouddrove/lambda/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true

  s3_bucket = "test-mysql-backups"
  s3_key    = "lambda_function_payload.zip"
  handler   = "index.handler"
  runtime   = "nodejs8.10"
  variables = {
    foo = "bar"
  }
}
