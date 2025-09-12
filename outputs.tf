# Module      : Lambda
# Description : Terraform Lambda function module outputs.
output "name" {
  description = "The name of the Lambda Function"
  value       = join("", aws_lambda_function.default[*].function_name)
}

output "arn" {
  value       = join("", aws_lambda_function.default[*].arn)
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}

output "lambda_log_group_name" {
  value       = !var.existing_cloudwatch_log_group ? aws_cloudwatch_log_group.lambda[0].name : 0
  description = "A mapping of tags to assign to the resource."
}

output "invoke_arn" {
  value       = join("", aws_lambda_function.default[*].invoke_arn)
  description = "Invoke ARN"
}



# inside modules/lambda/outputs.tf

output "lambda_function_url" {
  description = "The URL of the Lambda Function"
  value       = try(aws_lambda_function_url.this[0].function_url, "")
}

output "lambda_function_url_id" {
  description = "The Lambda Function URL generated id"
  value       = try(aws_lambda_function_url.this[0].url_id, "")
}

output "lambda_provisioned_concurrency_config_id" {
  description = "The ID of the Lambda Provisioned Concurrency Config"
  value       = try(aws_lambda_provisioned_concurrency_config.current_version[0].id, "")
}

output "lambda_recursion_config_function_name" {
  description = "The Lambda Function name associated with the Recursion Config"
  value       = try(aws_lambda_function_recursion_config.this[0].function_name, "")
}