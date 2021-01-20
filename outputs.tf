# Module      : Lambda
# Description : Terraform Lambda function module outputs.
output "arn" {
  value       = join("", aws_lambda_function.default.*.arn)
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}