provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../../"

  name        = "lambda"
  environment = "test"
  label_order = ["name", "environment"]

  enable    = true
  s3_bucket = "test-s3-backups"
  s3_key    = "lambda_function_payload.zip"
  handler   = "index.handler"
  runtime   = "nodejs8.10"
  variables = {
    foo = "bar"
  }
}
