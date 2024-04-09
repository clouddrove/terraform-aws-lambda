provider "aws" {
  region = "us-east-1"
}

locals {
  name        = "lambda"
  environment = "test"
}

##-----------------------------------------------------------------------------
## lambda Module Call with s3_bucket.
##-----------------------------------------------------------------------------
module "lambda" {
  source      = "../../"
  name        = local.name
  environment = local.environment
  s3_bucket   = "clouddrove-secure-bucket-test"
  s3_key      = "index.zip"
  handler     = "index.handler"
  runtime     = "nodejs18.x"
  variables = {
    foo = "bar"
  }
}
