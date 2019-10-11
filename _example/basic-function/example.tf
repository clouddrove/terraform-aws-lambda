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

  filename = "./../../../lambda_packages"
  handler  = "index.lambda_handler"
  runtime  = "python3.7"
  iam_actions = [
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents",
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface",
    "ec2:DescribeSecurityGroups",
  ]
  variables = {
    foo = "bar"
  }
}
