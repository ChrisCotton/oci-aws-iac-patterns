# AWS outputs (empty string when AWS disabled)
output "aws_vpc_id" {
  value = length(aws_vpc.this) > 0 ? aws_vpc.this[0].id : ""
}

output "aws_subnet_id" {
  value = length(aws_subnet.this) > 0 ? aws_subnet.this[0].id : ""
}

output "aws_security_group_id" {
  value = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : ""
}

# OCI outputs (empty string when OCI disabled)
output "oci_vcn_id" {
  value = length(oci_core_vcn.this) > 0 ? oci_core_vcn.this[0].id : ""
}

output "oci_subnet_id" {
  value = length(oci_core_subnet.this) > 0 ? oci_core_subnet.this[0].id : ""
}

output "oci_security_list_id" {
  value = length(oci_core_security_list.this) > 0 ? oci_core_security_list.this[0].id : ""
}
