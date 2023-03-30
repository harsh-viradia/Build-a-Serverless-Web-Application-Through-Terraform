# ------------------------------------------------------------------IAM role for lambda ------------------------------------------------
data "aws_iam_policy_document" "harsh_viradia_assume_lambda_role" {
statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name                = "harsh-viradia-wildrides"
  assume_role_policy  = join("", data.aws_iam_policy_document.harsh_viradia_assume_lambda_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "dynamodb_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["dynamodb:PutItem"]
          Effect   = "Allow"
          Resource = "arn:aws:dynamodb:us-east-1:587172484624:table/harsh-viradia-wildrides-db-table"
        },
      ]
    })
  }
}

# -------------------------------------------------------------------- Lambda Function ---------------------------------------------------

data "archive_file" "harsh-viradia-lambda" {
  type = "zip"
  source_file = "index.js"
  output_path = "harsh_lambda_function_payload.zip"
}

resource "aws_lambda_function" "harsh-viradia-lambda-function" {
  filename = "harsh_lambda_function_payload.zip"
  function_name = "harsh-viradia-wildrides-lambda"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs16.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.harsh-viradia-lambda.output_base64sha256
}