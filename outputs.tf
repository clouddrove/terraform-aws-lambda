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

output "lambda_log_group_name" {
  value       = aws_cloudwatch_log_group.lambda[0].name
  description = "A mapping of tags to assign to the resource."
}