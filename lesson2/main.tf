terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "random_pet" "suffix" {
  length = 2
}

resource "aws_s3_bucket" "study" {
  bucket = "terraform-study-${random_pet.suffix.id}"

  tags = {
    Env       = "study"
    ManagedBy = "terraform"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.study.bucket
}