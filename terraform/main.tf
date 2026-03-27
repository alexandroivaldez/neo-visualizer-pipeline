terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
      archive = {
        source  = "hashicorp/archive"
        version = "~> 2.0"
      }
    }

    backend "s3" {
        bucket = "neo-visualizer-pipeline"
        key    = "terraform/state.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_s3_bucket" "neo_data" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "neo_data" {
  bucket = aws_s3_bucket.neo_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/handler.py"
  output_path = "${path.module}/../lambda/handler.zip"
}

resource "aws_lambda_function" "neo_pipeline" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "neo-pipeline"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.handler"
  runtime          = "python3.11"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      NASA_API_KEY = var.nasa_api_key
      S3_BUCKET    = var.bucket_name
    }
  }
}