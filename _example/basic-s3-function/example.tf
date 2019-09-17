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

  s3_bucket = "test-mysql-backups"
  s3_key    = "lambda_function_payload.zip"
  handler   = "index.handler"
  runtime   = "nodejs8.10"
}
