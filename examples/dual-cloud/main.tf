# ============================================================
# Example: Dual-cloud deployment (AWS + OCI simultaneously)
# The flagship use case: equivalent infrastructure in both clouds
# from a single Terraform apply.
# ============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.oci_region
}

module "dualcloud" {
  source = "../.."

  project_name = "dualcloud-demo"
  environment  = "dev"

  aws_enabled = true
  oci_enabled = true

  # AWS config
  aws_region        = var.aws_region
  aws_instance_type = "t3.micro"

  # OCI config
  oci_tenancy_ocid       = var.oci_tenancy_ocid
  oci_user_ocid          = var.oci_user_ocid
  oci_fingerprint        = var.oci_fingerprint
  oci_private_key_path   = var.oci_private_key_path
  oci_region             = var.oci_region
  oci_compartment_ocid   = var.oci_compartment_ocid
  oci_instance_shape     = "VM.Standard.E4.Flex"
  oci_instance_ocpus     = 1
  oci_instance_memory_gb = 1
  oci_ssh_public_key     = var.oci_ssh_public_key
}

# Variables
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "oci_tenancy_ocid" {
  type = string
}

variable "oci_user_ocid" {
  type = string
}

variable "oci_fingerprint" {
  type = string
}

variable "oci_private_key_path" {
  type = string
}

variable "oci_region" {
  type    = string
  default = "us-sanjose-1"
}

variable "oci_compartment_ocid" {
  type = string
}

variable "oci_ssh_public_key" {
  type = string
}

# Show what was provisioned
output "aws_instance_public_ip" {
  value = module.dualcloud.aws_instance_public_ips
}

output "oci_instance_public_ip" {
  value = module.dualcloud.oci_instance_public_ips
}
