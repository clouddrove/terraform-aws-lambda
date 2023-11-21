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

output "tags" {
  value       = module.lambda.tags
  description = "A mapping of tags to assign to the resource."
}
