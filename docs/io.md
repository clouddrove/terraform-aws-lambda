## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| actions | The AWS Lambda action you want to allow in this statement. (e.g. lambda:InvokeFunction). | `list(any)` | `[]` | no |
| architectures | Instruction set architecture for your Lambda function. Valid values are ["x86\_64"] and ["arm64"]. | `list(string)` | `null` | no |
| assume\_role\_policy | assume role policy document in JSON format | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}\n"` | no |
| attach\_cloudwatch\_logs\_policy | Controls whether CloudWatch Logs policy should be added to IAM role for Lambda Function | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| aws\_iam\_policy\_path | IAM policy path default value | `string` | `"/"` | no |
| cloudwatch\_logs\_kms\_key\_arn | The arn for the KMS encryption key for cloudwatch log group | `string` | `null` | no |
| cloudwatch\_logs\_retention\_in\_days | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `null` | no |
| code\_signing\_config\_arn | Amazon Resource Name (ARN) for a Code Signing Configuration | `string` | `null` | no |
| compatible\_architectures | List of Architectures lambda layer is compatible with. Currently x86\_64 and arm64 can be specified. | `list(string)` | `null` | no |
| compatible\_runtimes | A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified. | `list(any)` | `[]` | no |
| create\_iam\_role | Flag to control creation of iam role and its related resources. | `bool` | `true` | no |
| create\_layers | Flag to control creation of lambda layers. | `bool` | `false` | no |
| dead\_letter\_target\_arn | The ARN of an SNS topic or SQS queue to notify when an invocation fails. | `string` | `null` | no |
| description | Description of what your Lambda Function does. | `string` | `""` | no |
| descriptions | Description of what your Lambda Layer does. | `list(any)` | `[]` | no |
| enable | Whether to create lambda function. | `bool` | `true` | no |
| enable\_key\_rotation | Specifies whether key rotation is enabled. Defaults to true(security best practice) | `bool` | `true` | no |
| enable\_kms | Flag to control creation of kms key for lambda encryption | `bool` | `true` | no |
| enable\_source\_code\_hash | Whether to ignore changes to the function's source code hash. Set to true if you manage infrastructure and code deployments separately. | `bool` | `false` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| ephemeral\_storage\_size | Amount of ephemeral storage (/tmp) in MB your Lambda Function can use at runtime. Valid value between 512 MB to 10,240 MB (10 GB). | `number` | `512` | no |
| event\_source\_tokens | The Event Source Token to validate. Used with Alexa Skills. | `list(any)` | `[]` | no |
| existing\_cloudwatch\_log\_group | Whether to use an existing CloudWatch log group or create new | `bool` | `false` | no |
| existing\_cloudwatch\_log\_group\_name | Name of existing cloudwatch log group. | `string` | `null` | no |
| file\_system\_arn | The Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system. | `string` | `null` | no |
| file\_system\_local\_mount\_path | The path where the function can access the file system, starting with /mnt/. | `string` | `null` | no |
| filename | The path to the function's deployment package within the local filesystem. If defined, The s3\_-prefixed options cannot be used. | `string` | `null` | no |
| handler | The function entrypoint in your code. | `string` | n/a | yes |
| iam\_actions | The actions for Iam Role Policy. | `list(any)` | <pre>[<br>  "logs:CreateLogStream",<br>  "logs:CreateLogGroup",<br>  "logs:PutLogEvents"<br>]</pre> | no |
| iam\_role\_arn | Iam Role arn to be attached to lambda function. | `string` | `null` | no |
| image\_config\_command | The CMD for the docker image | `list(string)` | `[]` | no |
| image\_config\_entry\_point | The ENTRYPOINT for the docker image | `list(string)` | `[]` | no |
| image\_config\_working\_directory | The working directory for the docker image | `string` | `null` | no |
| image\_uri | The ECR image URI containing the function's deployment package. | `string` | `null` | no |
| kms\_key\_deletion\_window | KMS Key deletion window in days. | `number` | `10` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| lambda\_kms\_key\_arn | The ARN for the KMS encryption key. | `string` | `null` | no |
| layer\_filenames | The path to the function's deployment package within the local filesystem. If defined, The s3\_-prefixed options cannot be used. | `list(any)` | `[]` | no |
| layer\_names | A unique name for your Lambda Layer. | `list(any)` | `[]` | no |
| layers | List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. | `list(string)` | `null` | no |
| license\_infos | License info for your Lambda Layer. See License Info. | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| memory\_size | Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. | `number` | `128` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| package\_type | The Lambda deployment package type. Valid options: Zip or Image | `string` | `"Zip"` | no |
| policy\_path | Path of policies to that should be added to IAM role for Lambda Function | `string` | `null` | no |
| principal\_org\_id | The identifier for your organization in AWS Organizations. Use this to grant permissions to all the AWS accounts under this organization. | `string` | `null` | no |
| principals | The principal who is getting this permission. e.g. s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com. | `list(any)` | `[]` | no |
| publish | Whether to publish creation/change as new Lambda Function Version. Defaults to false. | `bool` | `false` | no |
| qualifiers | Query parameter to specify function version or alias name. The permission will then apply to the specific qualified ARN. e.g. arn:aws:lambda:aws-region:acct-id:function:function-name:2 | `list(any)` | `[]` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-lambda"` | no |
| reserved\_concurrent\_executions | The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. | `number` | `90` | no |
| runtime | Runtimes. | `string` | `"python3.7"` | no |
| s3\_bucket | The S3 bucket location containing the function's deployment package. Conflicts with filename. This bucket must reside in the same AWS region where you are creating the Lambda function. | `string` | `null` | no |
| s3\_buckets | The S3 bucket location containing the function's deployment package. Conflicts with filename. This bucket must reside in the same AWS region where you are creating the Lambda function. | `list(any)` | `[]` | no |
| s3\_keies | The S3 key of an object containing the function's deployment package. Conflicts with filename. | `list(any)` | `[]` | no |
| s3\_key | The S3 key of an object containing the function's deployment package. Conflicts with filename. | `string` | `null` | no |
| s3\_object\_version | The object version containing the function's deployment package. Conflicts with filename. | `string` | `null` | no |
| s3\_object\_versions | The object version containing the function's deployment package. Conflicts with filename. | `list(any)` | `[]` | no |
| security\_group\_ids | Security group ids for vpc config. | `list(any)` | `[]` | no |
| skip\_destroy | Whether to retain the old version of a previously deployed Lambda Layer. | `bool` | `false` | no |
| snap\_start | (Optional) Snap start settings for low-latency startups | `bool` | `false` | no |
| source\_accounts | This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner. | `list(any)` | `[]` | no |
| source\_arns | When granting Amazon S3 or CloudWatch Events permission to invoke your function, you should specify this field with the Amazon Resource Name (ARN) for the S3 Bucket or CloudWatch Events Rule as its value. This ensures that only events generated from the specified bucket or rule can invoke the function. | `list(any)` | `[]` | no |
| source\_file | Path of source file that is required to be converted in `.zip` file | `string` | `null` | no |
| statement\_ids | A unique statement identifier. By default generated by Terraform. | `list(any)` | `[]` | no |
| subnet\_ids | Subnet ids for vpc config. | `list(any)` | `[]` | no |
| timeout | The amount of time in seconds your Lambda Function will run. Defaults to 3. | `number` | `10` | no |
| tracing\_mode | Tracing mode of the Lambda Function. Valid value can be either PassThrough or Active. | `string` | `null` | no |
| variables | A map that defines environment variables for the Lambda function. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name (ARN) identifying your Lambda Function. |
| invoke\_arn | Invoke ARN |
| lambda\_log\_group\_name | A mapping of tags to assign to the resource. |
| name | The name of the Lambda Function |
| tags | A mapping of tags to assign to the resource. |
