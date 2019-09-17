# Module      : Lambda
# Description : Terraform module to create Lambda resource on AWS for managing queue.
output "arn" {
  value = concat(
    aws_lambda_function.default.*.arn,
  )[0]
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}