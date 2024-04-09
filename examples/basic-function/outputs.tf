output "arn" {
  value       = module.lambda[*].arn
  description = "The ID of the Hostzone."
}

output "tags" {
  value       = module.lambda.tags
  description = "A mapping of tags to assign to the resource."
}
