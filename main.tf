# Managed By : CloudDrove
# Description : Terraform module to create Iam role resource on AWS for lambda.
# Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = var.attributes
  label_order = var.label_order
}

# Module      : Lambda layers
# Description : Terraform module to create Lambda layers resource on AWS.
resource "aws_lambda_layer_version" "default" {
  count                    = var.enable && var.create_layers ? length(var.names) : 0
  layer_name               = element(var.names, count.index)
  description              = length(var.descriptions) > 0 ? element(var.descriptions, count.index) : ""
  license_info             = length(var.license_infos) > 0 ? element(var.license_infos, count.index) : ""
  filename                 = length(var.layer_filenames) > 0 ? element(var.layer_filenames, count.index) : null
  s3_bucket                = length(var.s3_buckets) > 0 ? element(var.s3_buckets, count.index) : null
  s3_key                   = length(var.s3_keies) > 0 ? element(var.s3_keies, count.index) : null
  s3_object_version        = length(var.s3_object_versions) > 0 ? element(var.s3_object_versions, count.index) : null
  compatible_runtimes      = element(var.compatible_runtimes, count.index)
  compatible_architectures = element(var.compatible_architectures, count.index)
  skip_destroy             = var.skip_destroy
  source_code_hash         = var.enable_source_code_hash ? filebase64sha256(element(var.layer_filenames, count.index)) : null
}

# Module      : Archive file
# Description : Terraform module to zip a directory.
data "archive_file" "default" {
  count       = var.enable && var.source_file != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_file
  output_path = format("%s.zip", module.labels.id)
}

# Module      : Lambda function
# Description : Terraform module to create Lambda function resource on AWS.
resource "aws_lambda_function" "default" {
  count                          = var.enable ? 1 : 0
  function_name                  = module.labels.id
  description                    = var.description
  role                           = var.create_iam_role ? join("", aws_iam_role.default.*.arn) : var.iam_role_arn
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.runtime
  layers                         = var.create_layers ? aws_lambda_layer_version.default.*.arn : var.layers
  timeout                        = var.timeout
  publish                        = var.publish
  kms_key_arn                    = var.kms_key_arn == null ? aws_kms_key.kms[0].arn : var.kms_key_arn
  image_uri                      = var.image_uri
  package_type                   = var.package_type
  architectures                  = var.architectures
  code_signing_config_arn        = var.code_signing_config_arn
  filename                       = var.source_file != null ? format("%s.zip", module.labels.id) : var.filename != null ? var.filename : null
  s3_bucket                      = var.s3_bucket
  s3_key                         = var.s3_key
  s3_object_version              = var.s3_object_version
  source_code_hash               = var.enable_source_code_hash ? filebase64sha256(var.filename) : null
  tags                           = module.labels.tags

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size == null ? [] : [true]

    content {
      size = var.ephemeral_storage_size
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_arn != null && var.file_system_local_mount_path != null ? [true] : []
    content {
      local_mount_path = var.file_system_local_mount_path
      arn              = var.file_system_arn
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode == null ? [] : [true]
    content {
      mode = var.tracing_mode
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn == null ? [] : [true]
    content {
      target_arn = var.dead_letter_target_arn
    }
  }


  dynamic "snap_start" {
    for_each = var.snap_start ? [true] : []

    content {
      apply_on = "PublishedVersions"
    }
  }

  dynamic "image_config" {
    for_each = length(var.image_config_entry_point) > 0 || length(var.image_config_command) > 0 || var.image_config_working_directory != null ? [true] : []
    content {
      entry_point       = var.image_config_entry_point
      command           = var.image_config_command
      working_directory = var.image_config_working_directory
    }
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  dynamic "environment" {
    for_each = length(keys(var.variables)) == 0 ? [] : [true]
    content {
      variables = var.variables
    }
  }

  lifecycle {
    # Ignore tags added by kubernetes
    ignore_changes = [
      source_code_hash,
    ]
  }
  depends_on = [aws_iam_role_policy_attachment.default]
}

# Module      : Lambda Permission
# Description : Terraform module to create Lambda permission resource on AWS to create
#               trigger for function.
resource "aws_lambda_permission" "default" {
  count = var.enable && length(var.actions) > 0 ? length(var.actions) : 0

  statement_id       = length(var.statement_ids) > 0 ? element(var.statement_ids, count.index) : ""
  event_source_token = length(var.event_source_tokens) > 0 ? element(var.event_source_tokens, count.index) : null
  action             = element(var.actions, count.index)
  function_name      = join("", aws_lambda_function.default.*.function_name)
  principal          = element(var.principals, count.index)
  qualifier          = length(var.qualifiers) > 0 ? element(var.qualifiers, count.index) : null
  source_account     = length(var.source_accounts) > 0 ? element(var.source_accounts, count.index) : null
  source_arn         = length(var.source_arns) > 0 ? element(var.source_arns, count.index) : ""
  principal_org_id   = var.principal_org_id
}

# Module      : Iam role
# Description : Terraform module to create Iam role resource on AWS for lambda.
resource "aws_iam_role" "default" {
  count = var.enable && var.create_iam_role ? 1 : 0
  name  = format("%s-role", module.labels.id)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Module      : Iam policy
# Description : Terraform module to create Iam policy resource on AWS for lambda.
resource "aws_iam_policy" "default" {
  count       = var.enable && var.create_iam_role ? 1 : 0
  name        = format("%s-logging", module.labels.id)
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.default.json
}
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "default" {
  statement {
    actions   = var.iam_actions
    effect    = "Allow"
    resources = ["*"]
  }
}

# Module      : Iam Role Policy Attachment
# Description : Terraform module to attach Iam policy with role resource on AWS for lambda.
resource "aws_iam_role_policy_attachment" "default" {
  count = var.enable && var.create_iam_role ? 1 : 0

  role       = join("", aws_iam_role.default.*.name)
  policy_arn = join("", aws_iam_policy.default.*.arn)
}

##-----------------------------------------------------------------------------
## Below resource will create kms key. This key will used for encryption lambda function variables.
##-----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "kms" {
  count                   = var.enable && var.enable_kms ? 1 : 0
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.enable_key_rotation
}

resource "aws_kms_alias" "kms-alias" {
  count         = var.enable && var.enable_kms ? 1 : 0
  name          = format("alias/%s-lambda-key", module.labels.id)
  target_key_id = aws_kms_key.kms[0].key_id
}

##-----------------------------------------------------------------------------
## Below resource will attach policy to above created kms key. The above created key require policy to be attached so that lambda can access it. 
## It will be only created when kms key is enabled. 
##-----------------------------------------------------------------------------
resource "aws_kms_key_policy" "example" {
  count  = var.enable && var.enable_kms ? 1 : 0
  key_id = aws_kms_key.kms[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "lambda.${data.aws_region.current.name}.amazonaws.com" },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*"
      }
    ]
  })

}

# locals {
#   log_group_arn_regional = try(data.aws_cloudwatch_log_group.lambda[0].arn, aws_cloudwatch_log_group.lambda[0].arn, "")
#   log_group_name         = try(data.aws_cloudwatch_log_group.lambda[0].name, aws_cloudwatch_log_group.lambda[0].name, "")
#   log_group_arn          = var.create_iam_role  ? format("arn:%s:%s:%s:%s:%s", data.aws_arn.log_group_arn[0].partition, data.aws_arn.log_group_arn[0].service, var.lambda_at_edge_logs_all_regions ? "*" : "us-east-1", data.aws_arn.log_group_arn[0].account, data.aws_arn.log_group_arn[0].resource) : local.log_group_arn_regional
# }

# data "aws_cloudwatch_log_group" "lambda" {
#   count = local.create && var.create_function && !var.create_layer && var.use_existing_cloudwatch_log_group ? 1 : 0

#   name = "/aws/lambda/${module.labels.id}"
# }

# resource "aws_cloudwatch_log_group" "lambda" {
#   count = local.create && var.create_function && !var.create_layer && !var.use_existing_cloudwatch_log_group ? 1 : 0

#   name              = "/aws/lambda/${module.labels.id}"
#   retention_in_days = var.cloudwatch_logs_retention_in_days
#   kms_key_id        = var.cloudwatch_logs_kms_key_id

#   tags = merge(var.tags, var.cloudwatch_logs_tags)
# }

# data "aws_arn" "log_group_arn" {
#   count = var.create_iam_role ? 1 : 0
#   arn = local.log_group_arn_regional
# }

# data "aws_iam_policy_document" "logs" {
#   count = local.create_role && var.attach_cloudwatch_logs_policy ? 1 : 0
#   statement {
#     effect = "Allow"
#     actions = compact([
#       !var.use_existing_cloudwatch_log_group ? "logs:CreateLogGroup" : "",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ])
#     resources = flatten([for _, v in ["%v:*", "%v:*:*"] : format(v, local.log_group_arn)])
#   }
# }

# resource "aws_iam_policy" "logs" {
#   count = var.enable && var.create_iam_role && var.attach_cloudwatch_logs_policy ? 1 : 0
#   name   = "aws_lambda-logs"
#   path   = var.policy_path
#   policy = data.aws_iam_policy_document.logs[0].json
#   tags   = module.labels.tags
# }

# resource "aws_iam_role_policy_attachment" "logs" {
#   count = var.enable && var.create_iam_role && var.attach_cloudwatch_logs_policy ? 1 : 0
#   role       = aws_iam_role.default[0].name
#   policy_arn = aws_iam_policy.logs[0].arn
# }