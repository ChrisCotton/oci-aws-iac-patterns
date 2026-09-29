variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC/VCN"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
}

variable "aws_enabled" {
  description = "Provision AWS networking"
  type        = bool
  default     = false
}

variable "oci_enabled" {
  description = "Provision OCI networking"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "oci_region" {
  description = "OCI region"
  type        = string
  default     = "us-sanjose-1"
}

variable "oci_compartment" {
  description = "OCI compartment OCID"
  type        = string
  default     = ""
}
