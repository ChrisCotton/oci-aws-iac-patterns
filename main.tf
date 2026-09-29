# ============================================================
# Dual-Cloud IaC: AWS + OCI
# This root module provisions equivalent infrastructure in both
# clouds using a single interface. The abstraction layer ensures
# the same variables produce comparable resources in each cloud.
# ============================================================

# Network module: provisions VPC (AWS) and VCN (OCI)
module "network" {
  source = "./modules/network"

  project_name      = var.project_name
  environment       = var.environment
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  aws_enabled       = var.aws_enabled
  oci_enabled       = var.oci_enabled
  aws_region        = var.aws_region
  oci_region        = var.oci_region
  oci_compartment   = var.oci_compartment_ocid
}

# Compute module: provisions EC2 (AWS) and compute instances (OCI)
module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  environment         = var.environment
  instance_count      = var.instance_count

  # AWS
  aws_enabled         = var.aws_enabled
  aws_instance_type   = var.aws_instance_type
  aws_ami_id          = var.aws_ami_id
  aws_subnet_id       = module.network.aws_subnet_id
  aws_security_group  = module.network.aws_security_group_id
  aws_ssh_public_key  = var.aws_ssh_public_key

  # OCI
  oci_enabled         = var.oci_enabled
  oci_compartment     = var.oci_compartment_ocid
  oci_image_ocid      = var.oci_image_ocid
  oci_instance_shape  = var.oci_instance_shape
  oci_ocpus           = var.oci_instance_ocpus
  oci_memory_gb       = var.oci_instance_memory_gb
  oci_subnet_id       = module.network.oci_subnet_id
  oci_ssh_public_key  = var.oci_ssh_public_key

  depends_on = [module.network]
}
