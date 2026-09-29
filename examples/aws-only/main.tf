# ============================================================
# Example: AWS-only deployment
# Demonstrates the abstraction layer with only AWS enabled.
# ============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "dualcloud" {
  source = "../.."

  project_name = "aws-demo"
  environment  = "dev"

  aws_enabled = true
  oci_enabled = false

  aws_region        = "us-west-2"
  aws_instance_type = "t3.micro"
}
