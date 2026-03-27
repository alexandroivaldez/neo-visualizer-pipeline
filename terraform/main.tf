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