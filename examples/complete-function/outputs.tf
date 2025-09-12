# output "name" {
#   value       = aws_lambda_function.default.function_name
#   description = "The name can identifying your Lambda Function."
# }
output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = module.lambda.name
}

output "arn" {
  value       = module.lambda[*].arn
  description = "The ID of the Hostzone."
}

output "invoke_arn" {
  value       = module.lambda.invoke_arn
  description = "Invoke ARN of lambda function."
}

output "tags" {
  value       = module.lambda.tags
  description = "A mapping of tags to assign to the resource."
}


output "lambda_function_url" {
  value = module.lambda.lambda_function_url
}

output "lambda_function_url_id" {
  value = module.lambda.lambda_function_url_id
}

output "lambda_provisioned_concurrency_config_id" {
  value = module.lambda.lambda_provisioned_concurrency_config_id
}

output "lambda_recursion_config_function_name" {
  value = module.lambda.lambda_recursion_config_function_name
}


