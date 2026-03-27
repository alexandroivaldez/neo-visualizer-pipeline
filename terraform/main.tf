terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
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