##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/aws"
  version     = "1.3.0"
  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = var.attributes
  label_order = var.label_order
}

##-----------------------------------------------------------------------------
## Lambda Layers allow you to reuse shared bits of code across multiple lambda functions.
##-----------------------------------------------------------------------------
resource "aws_lambda_layer_version" "default" {
  count                    = var.enable && var.create_layers ? length(var.layer_names) : 0
  layer_name               = element(var.layer_names, count.index)
  description              = length(var.descriptions) > 0 ? element(var.descriptions, count.index) : ""
  license_info             = length(var.license_infos) > 0 ? element(var.license_infos, count.index) : ""
  filename                 = length(var.layer_filenames) > 0 ? element(var.layer_filenames, count.index) : null
  s3_bucket                = length(var.s3_buckets) > 0 ? element(var.s3_buckets, count.index) : null
  s3_key                   = length(var.s3_keies) > 0 ? element(var.s3_keies, count.index) : null
  s3_object_version        = length(var.s3_object_versions) > 0 ? element(var.s3_object_versions, count.index) : null
  compatible_runtimes      = element(var.compatible_runtimes, count.index)
  compatible_architectures = var.compatible_architectures
  skip_destroy             = var.skip_destroy
  source_code_hash         = var.enable_source_code_hash ? filebase64sha256(element(var.layer_filenames, count.index)) : null
}

##-----------------------------------------------------------------------------
## Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
##-----------------------------------------------------------------------------
#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "default" {
  count                          = var.enable ? 1 : 0
  function_name                  = module.labels.id
  description                    = var.description
  role                           = var.create_iam_role ? join("", aws_iam_role.default[*].arn) : var.iam_role_arn
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.runtime
  layers                         = var.create_layers ? aws_lambda_layer_version.default[*].arn : var.layers
  timeout                        = var.timeout
  publish                        = var.publish
  kms_key_arn                    = var.enable_kms ? aws_kms_key.kms[0].arn : var.lambda_kms_key_arn
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
  depends_on = [aws_iam_role_policy_attachment.default, aws_cloudwatch_log_group.lambda]
}

##-----------------------------------------------------------------------------
## IAM permissions that grant a specific AWS Cloud service or resource permission to invoke a Lambda function.
##-----------------------------------------------------------------------------
resource "aws_lambda_permission" "default" {
  count              = var.enable && length(var.actions) > 0 ? length(var.actions) : 0
  statement_id       = length(var.statement_ids) > 0 ? element(var.statement_ids, count.index) : null
  event_source_token = length(var.event_source_tokens) > 0 ? element(var.event_source_tokens, count.index) : null
  action             = element(var.actions, count.index)
  function_name      = join("", aws_lambda_function.default[*].function_name)
  principal          = element(var.principals, count.index)
  qualifier          = length(var.qualifiers) > 0 ? element(var.qualifiers, count.index) : null
  source_account     = length(var.source_accounts) > 0 ? element(var.source_accounts, count.index) : null
  source_arn         = length(var.source_arns) > 0 ? element(var.source_arns, count.index) : ""
  principal_org_id   = var.principal_org_id
}

##-----------------------------------------------------------------------------
## Terraform module to create Iam role resource on AWS for lambda.
##-----------------------------------------------------------------------------
resource "aws_iam_role" "default" {
  count              = var.enable && var.create_iam_role ? 1 : 0
  name               = format("%s-role", module.labels.id)
  assume_role_policy = var.assume_role_policy
}

##-----------------------------------------------------------------------------
## Terraform module to create Iam policy resource on AWS for lambda.
##-----------------------------------------------------------------------------
resource "aws_iam_policy" "default" {
  count       = var.enable && var.create_iam_role ? 1 : 0
  name        = format("%s-additional-permissions", module.labels.id)
  path        = var.aws_iam_policy_path
  description = "Additional permission for ${module.labels.id} Lambda Function IAMRole."
  policy      = data.aws_iam_policy_document.default[0].json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "default" {
  count = var.enable ? 1 : 0
  statement {
    actions   = var.iam_actions
    effect    = "Allow"
    resources = ["*"]
  }
}

##-----------------------------------------------------------------------------
## Terraform module to attach Iam policy with role resource on AWS for lambda.
##-----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "default" {
  count      = var.enable && var.create_iam_role ? 1 : 0
  role       = join("", aws_iam_role.default[*].name)
  policy_arn = join("", aws_iam_policy.default[*].arn)
}

##-----------------------------------------------------------------------------
## Below resource will create kms key. This key will used for encryption lambda function variables.
##-----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "kms" {
  count                   = var.enable && var.enable_kms ? !var.existing_cloudwatch_log_group ? 2 : 1 : 0
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.enable_key_rotation
}

resource "aws_kms_alias" "kms-alias" {
  count         = var.enable && var.enable_kms ? 1 : 0
  name          = format("alias/%s-lambda-keys", module.labels.id)
  target_key_id = aws_kms_key.kms[0].key_id
}

resource "aws_kms_alias" "kms-alias-cloudwatch" {
  count         = var.enable && var.enable_kms && !var.existing_cloudwatch_log_group ? 1 : 0
  name          = format("alias/%s-lambda-cloudwatch-keys", module.labels.id)
  target_key_id = aws_kms_key.kms[1].key_id
}

##-----------------------------------------------------------------------------
## Below resource will attach policy to above created kms key. The above created key require policy to be attached so that lambda can access it.
## It will be only created when kms key is enabled.
##-----------------------------------------------------------------------------
resource "aws_kms_key_policy" "lambda" {
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

resource "aws_kms_key_policy" "cloudwatch" {
  count  = var.enable && var.enable_kms && !var.existing_cloudwatch_log_group ? 1 : 0
  key_id = aws_kms_key.kms[1].id
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
        "Principal" : { "Service" : "logs.${data.aws_region.current.name}.amazonaws.com" },
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

locals {
  log_group_arn = try(data.aws_cloudwatch_log_group.lambda[0].arn, aws_cloudwatch_log_group.lambda[0].arn, "")
}

data "aws_cloudwatch_log_group" "lambda" {
  count = var.enable && var.existing_cloudwatch_log_group ? 1 : 0
  name  = var.existing_cloudwatch_log_group_name
}

resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.enable && !var.existing_cloudwatch_log_group ? 1 : 0
  name              = "/aws/lambda/${module.labels.id}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.enable_kms ? aws_kms_key.kms[1].arn : var.cloudwatch_logs_kms_key_arn
  tags              = module.labels.tags
}

data "aws_iam_policy_document" "logs" {
  count = var.enable && var.create_iam_role && var.attach_cloudwatch_logs_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = compact([
      !var.existing_cloudwatch_log_group ? "logs:CreateLogGroup" : "",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ])
    resources = flatten([for _, v in ["%v:*", "%v:*:*"] : format(v, local.log_group_arn)])
  }
}

resource "aws_iam_policy" "logs" {
  count  = var.enable && var.create_iam_role && var.attach_cloudwatch_logs_policy ? 1 : 0
  name   = format("%s-cloudwatch-logging", module.labels.id)
  path   = var.policy_path
  policy = data.aws_iam_policy_document.logs[0].json
  tags   = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "logs" {
  count      = var.enable && var.create_iam_role && var.attach_cloudwatch_logs_policy ? 1 : 0
  role       = aws_iam_role.default[0].name
  policy_arn = aws_iam_policy.logs[0].arn
}
