# ============================================================
# Example: OCI-only deployment
# Demonstrates the abstraction layer with only OCI enabled.
# Requires OCI credentials (tenancy OCID, user OCID, API key).
# ============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
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

  project_name = "oci-demo"
  environment  = "dev"

  aws_enabled = false
  oci_enabled = true

  oci_tenancy_ocid     = var.oci_tenancy_ocid
  oci_user_ocid        = var.oci_user_ocid
  oci_fingerprint      = var.oci_fingerprint
  oci_private_key_path = var.oci_private_key_path
  oci_region           = var.oci_region
  oci_compartment_ocid = var.oci_compartment_ocid
  oci_instance_shape   = "VM.Standard.E4.Flex"
  oci_instance_ocpus   = 1
  oci_instance_memory_gb = 1
  oci_ssh_public_key  = var.oci_ssh_public_key
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
