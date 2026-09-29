# AWS outputs
output "aws_instance_ids" {
  value = aws_instance.this[*].id
}

output "aws_instance_public_ips" {
  value = aws_instance.this[*].public_ip
}

# OCI outputs
output "oci_instance_ids" {
  value = oci_core_instance.this[*].id
}

output "oci_instance_public_ips" {
  value = oci_core_instance.this[*].public_ip
}
