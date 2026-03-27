variable "aws_region" {
    default = "us-east-1"
}

variable "bucket_name" {
    description = "Bucket for NEO data"
    type = string
    default     = "neo-visualizer-pipeline"
}

variable "nasa_api_key" {
    description = "NASA API key"
    type = string
    sensitive = true
}