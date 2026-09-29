# ============================================================
# Cloud Selection
# ============================================================

variable "aws_enabled" {
  description = "Provision AWS resources"
  type        = bool
  default     = true
}

variable "oci_enabled" {
  description = "Provision OCI resources"
  type        = bool
  default     = true
}

# ============================================================
# Common (shared across both clouds)
# ============================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "dualcloud-demo"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the virtual network (used by both AWS VPC and OCI VCN)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the primary subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_count" {
  description = "Number of compute instances to provision per cloud"
  type        = number
  default     = 1
}

variable "management_cidr" {
  description = "CIDR block for management access (e.g., SSH)"
  type        = string
  default     = "10.0.0.0/8"
}

# ============================================================
# AWS Configuration
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_ami_id" {
  description = "AMI ID for AWS instances (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

# ============================================================
# OCI Configuration
# ============================================================

variable "oci_tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  default     = ""
}

variable "oci_user_ocid" {
  description = "OCI user OCID"
  type        = string
  default     = ""
}

variable "oci_fingerprint" {
  description = "OCI API key fingerprint"
  type        = string
  default     = ""
}

variable "oci_private_key_path" {
  description = "Path to OCI API private key"
  type        = string
  default     = ""
}

variable "oci_region" {
  description = "OCI region"
  type        = string
  default     = "us-sanjose-1"
}

variable "oci_compartment_ocid" {
  description = "OCI compartment OCID for resource placement"
  type        = string
  default     = ""
}

variable "oci_vpc_cidr" {
  description = "CIDR block for the OCI VCN"
  type        = string
  default     = "172.16.0.0/16"
}

variable "oci_subnet_cidr" {
  description = "CIDR block for the OCI subnet"
  type        = string
  default     = "172.16.1.0/24"
}

variable "oci_instance_shape" {
  description = "OCI compute instance shape"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "oci_instance_ocpus" {
  description = "OCPU count for OCI flex shapes"
  type        = number
  default     = 1
}

variable "oci_instance_memory_gb" {
  description = "Memory (GB) for OCI flex shapes"
  type        = number
  default     = 1
}

variable "oci_image_ocid" {
  description = "OCI image OCID (leave empty to use latest Oracle Linux 8)"
  type        = string
  default     = ""
}

variable "oci_ssh_public_key" {
  description = "SSH public key for OCI instances"
  type        = string
  default     = ""
}

variable "aws_ssh_public_key" {
  description = "SSH public key for AWS instances"
  type        = string
  default     = ""
}
