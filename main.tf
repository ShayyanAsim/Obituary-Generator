terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

locals {
  // Lambda function names
  generate_name = "generate-obituary-30149567"
  read_name     = "read-obituary-30149567"
  store_name    = "store-files-30149567"
  save_name     = "save-item-30149567"
  create_name   = "create-obituary-30149567"
  get_name      = "get-obituaries-30149567"

  // Lambda handler names
  dynamodb_table_name = "last-show-30145507"
  generate_handler    = "generate_obituary.handler"
  read_handler        = "read_obituary.handler"
  store_handler       = "store_files.handler"
  save_handler        = "save_item.handler"
  create_handler      = "main.handler"
  get_handler         = "get_obituaries.handler"

  // Lambda zip files
  generate_artifact = "generate-artifact.zip"
  read_artifact     = "read-artifact.zip"
  store_artifact    = "store-artifact.zip"
  save_artifact     = "save-artifact.zip"
  create_artifact   = "create-artifact.zip"
  get_artifact      = "get-artifact.zip"
}
data "archive_file" "create_zip" {
  type        = "zip"
  source_dir  = "../functions/create-obituary/start"
  output_path = local.create_artifact
}
data "archive_file" "generate_zip" {
  type        = "zip"
  source_dir  = "../functions/create-obituary/generate-obituary"
  output_path = local.generate_artifact
}
data "archive_file" "read_zip" {
  type        = "zip"
  source_file = "../functions/create-obituary/read-obituary/read_obituary.py"
  output_path = local.read_artifact
}
data "archive_file" "store_zip" {
  type        = "zip"
  source_dir  = "../functions/create-obituary/store-files"
  output_path = local.store_artifact
}
data "archive_file" "save_zip" {
  type        = "zip"
  source_file = "../functions/create-obituary/save-item/save_item.py"
  output_path = local.save_artifact
}
data "archive_file" "get_zip" {
  type        = "zip"
  source_file = "../functions/get-obituaries/get_obituaries.py"
  output_path = local.get_artifact
}

# two lambda functions w/ function url

resource "aws_iam_role" "lambda-role" {
  name = "step-functions-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy" "logs" {
  name        = "lambda-logging-last-show"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "states:StartExecution",
        "states:DescribeExecution",
        "ssm:GetParametersByPath",
        "s3:*"
        
        
      ],
      "Resource":[
        "arn:aws:dynamodb:*:*:table/",
        "arn:aws:dynamodb:ca-central-1:294939119163:table/*",
        "arn:aws:logs:*:*:*",
        "arn:aws:lambda:*:*:*",
        "arn:aws:states:*:*:stateMachine:*",
        "arn:aws:states:ca-central-1:294939119163:execution:obituary_state_machine:*",
        "arn:aws:ssm:ca-central-1:294939119163:parameter/*",
        "arn:aws:s3::*:*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "polly:SynthesizeSpeech"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
        "Action" : [
          "states:DescribeExecution"
        ],
        "Resource" : [
          "arn:aws:states:ca-central-1:294939119163:execution:obituary_state_machine:*"
        ],
        "Effect" : "Allow"
      }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "logs-attachment" {
  role       = aws_iam_role.lambda-role.id
  policy_arn = aws_iam_policy.logs.arn
}

/// LAMBDA FUNCTIONS ///
resource "aws_lambda_function" "create-obituary-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.create_name
  handler          = local.create_handler
  filename         = local.create_artifact
  source_code_hash = data.archive_file.create_zip.output_base64sha256
  timeout          = 20
  runtime          = "python3.9"
}
resource "aws_lambda_function" "generate-obituary-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.generate_name
  handler          = local.generate_handler
  filename         = local.generate_artifact
  source_code_hash = data.archive_file.generate_zip.output_base64sha256
  timeout          = 20

  runtime = "python3.9"

}
resource "aws_lambda_function" "read-obituary-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.read_name
  handler          = local.read_handler
  filename         = local.read_artifact
  source_code_hash = data.archive_file.read_zip.output_base64sha256

  runtime = "python3.9"
}
resource "aws_lambda_function" "store-files-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.store_name
  handler          = local.store_handler
  filename         = local.store_artifact
  source_code_hash = data.archive_file.store_zip.output_base64sha256

  runtime = "python3.9"
}
resource "aws_lambda_function" "save-items-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.save_name
  handler          = local.save_handler
  filename         = local.save_artifact
  source_code_hash = data.archive_file.save_zip.output_base64sha256

  runtime = "python3.9"
}
resource "aws_lambda_function" "get-obituaries-lambda" {
  role             = aws_iam_role.lambda-role.arn
  function_name    = local.get_name
  handler          = local.get_handler
  filename         = local.get_artifact
  source_code_hash = data.archive_file.get_zip.output_base64sha256

  runtime = "python3.9"
}

# one dynamodb table
# Dynamo table
resource "aws_dynamodb_table" "the-last-show-30145507" {
  name           = "the-last-show-30145507"
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "S"
  }
}

# roles and policies as needed
# step functions (if you're going for the bonus marks)
resource "aws_sfn_state_machine" "obituary_state_machine" {
  name     = "obituary_state_machine"
  role_arn = aws_iam_role.lambda-role.arn


  definition = jsonencode({
    Comment = "Orchestrate Lambda functions to create an obituary"
    StartAt = "GenerateObituary"

    States = {
      GenerateObituary = {
        Type       = "Task"
        Resource   = aws_lambda_function.generate-obituary-lambda.arn
        InputPath  = "$.input"
        ResultPath = "$.results.generate"
        Next       = "ReadObituary"
      }
      ReadObituary = {
        Type       = "Task"
        Resource   = aws_lambda_function.read-obituary-lambda.arn
        InputPath  = "$.results.generate"
        ResultPath = "$.results.read"
        Next       = "StoreFiles"
      }
      StoreFiles = {
        Type       = "Task"
        Resource   = aws_lambda_function.store-files-lambda.arn
        InputPath  = "$.results"
        ResultPath = "$.results.store"
        Next       = "SaveItem"
      }
      SaveItem = {
        Type       = "Task"
        InputPath  = "$.results"
        ResultPath = "$.results.save"
        OutputPath = "$.results.save"
        Resource   = aws_lambda_function.save-items-lambda.arn
        End        = true
      }
    }

  })
}

resource "aws_s3_bucket" "the-last-show-s3" {
  bucket = "the-last-show-s3"

  tags = {
    Name = "Example Bucket"
  }
}

resource "aws_lambda_function_url" "url-create-obituary" {
  function_name      = aws_lambda_function.create-obituary-lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}
resource "aws_lambda_function_url" "url-get-obituaries" {
  function_name      = aws_lambda_function.get-obituaries-lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

output "url" {
  value = aws_lambda_function_url.url-create-obituary.function_url
}
output "get-url" {
  value = aws_lambda_function_url.url-get-obituaries.function_url

}