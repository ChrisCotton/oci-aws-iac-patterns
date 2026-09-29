variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_count" {
  description = "Number of instances per cloud"
  type        = number
  default     = 1
}

# AWS
variable "aws_enabled" {
  description = "Provision AWS instances"
  type        = bool
  default     = false
}

variable "aws_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_ami_id" {
  description = "AWS AMI ID (empty = latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "aws_subnet_id" {
  description = "AWS subnet ID"
  type        = string
  default     = ""
}

variable "aws_security_group" {
  description = "AWS security group ID"
  type        = string
  default     = ""
}

variable "aws_ssh_public_key" {
  description = "SSH public key for AWS instances"
  type        = string
  default     = ""
}

# OCI
variable "oci_enabled" {
  description = "Provision OCI instances"
  type        = bool
  default     = false
}

variable "oci_compartment" {
  description = "OCI compartment OCID"
  type        = string
  default     = ""
}

variable "oci_image_ocid" {
  description = "OCI image OCID (empty = latest Oracle Linux 8)"
  type        = string
  default     = ""
}

variable "oci_instance_shape" {
  description = "OCI instance shape"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "oci_ocpus" {
  description = "OCI OCPU count (flex shapes)"
  type        = number
  default     = 1
}

variable "oci_memory_gb" {
  description = "OCI memory in GB (flex shapes)"
  type        = number
  default     = 1
}

variable "oci_subnet_id" {
  description = "OCI subnet ID"
  type        = string
  default     = ""
}

variable "oci_ssh_public_key" {
  description = "SSH public key for OCI instances"
  type        = string
  default     = ""
}
