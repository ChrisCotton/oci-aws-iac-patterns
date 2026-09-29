# ============================================================
# Normalized outputs: consumers don't need to know which cloud
# ============================================================

# AWS outputs
output "aws_vpc_id" {
  description = "AWS VPC ID (empty if AWS disabled)"
  value       = module.network.aws_vpc_id
}

output "aws_subnet_id" {
  description = "AWS subnet ID (empty if AWS disabled)"
  value       = module.network.aws_subnet_id
}

output "aws_instance_ids" {
  description = "AWS EC2 instance IDs (empty if AWS disabled)"
  value       = module.compute.aws_instance_ids
}

output "aws_instance_public_ips" {
  description = "AWS instance public IPs (empty if AWS disabled)"
  value       = module.compute.aws_instance_public_ips
}

# OCI outputs
output "oci_vcn_id" {
  description = "OCI VCN ID (empty if OCI disabled)"
  value       = module.network.oci_vcn_id
}

output "oci_subnet_id" {
  description = "OCI subnet ID (empty if OCI disabled)"
  value       = module.network.oci_subnet_id
}

output "oci_instance_ids" {
  description = "OCI compute instance IDs (empty if OCI disabled)"
  value       = module.compute.oci_instance_ids
}

output "oci_instance_public_ips" {
  description = "OCI instance public IPs (empty if OCI disabled)"
  value       = module.compute.oci_instance_public_ips
}
