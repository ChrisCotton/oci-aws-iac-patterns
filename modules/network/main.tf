# ============================================================
# Network Abstraction Module
# Provisions equivalent networking in AWS (VPC) and OCI (VCN)
# Same interface, different implementations per cloud.
# ============================================================

# -----------------------------------------------------------
# AWS: VPC + Subnet + Internet Gateway + Route Table + SG
# -----------------------------------------------------------

resource "aws_vpc" "this" {
  count                = var.aws_enabled ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.aws_enabled ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "this" {
  count                   = var.aws_enabled ? 1 : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-${var.environment}-subnet"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "this" {
  count  = var.aws_enabled ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rt"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table_association" "this" {
  count          = var.aws_enabled ? 1 : 0
  subnet_id      = aws_subnet.this[0].id
  route_table_id = aws_route_table.this[0].id
}

resource "aws_security_group" "this" {
  count       = var.aws_enabled ? 1 : 0
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------
# OCI: VCN + Subnet + Internet Gateway + Route Table + SL
# -----------------------------------------------------------

# Look up the latest Oracle Linux 8 image for OCI (only if OCI enabled)
data "oci_core_images" "ol8" {
  count                  = var.oci_enabled ? 1 : 0
  compartment_id         = var.oci_compartment
  operating_system       = "Oracle Linux"
  operating_system_version = "8"
  shape                  = "VM.Standard.E4.Flex"
  sort_by                = "TIMECREATED"
  sort_order             = "DESC"
}

resource "oci_core_vcn" "this" {
  count              = var.oci_enabled ? 1 : 0
  compartment_id     = var.oci_compartment
  cidr_block         = var.vpc_cidr
  display_name       = "${var.project_name}-${var.environment}-vcn"
  dns_label          = substr(var.project_name, 0, 15)

  freeform_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "oci_core_internet_gateway" "this" {
  count          = var.oci_enabled ? 1 : 0
  compartment_id = var.oci_compartment
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.project_name}-${var.environment}-igw"

  freeform_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "oci_core_default_route_table" "this" {
  count                  = var.oci_enabled ? 1 : 0
  manage_default_resource_id = oci_core_vcn.this[0].default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
  }
}

# OCI subnets are regional (span all availability domains)
resource "oci_core_subnet" "this" {
  count               = var.oci_enabled ? 1 : 0
  compartment_id      = var.oci_compartment
  vcn_id              = oci_core_vcn.this[0].id
  cidr_block          = var.subnet_cidr
  display_name        = "${var.project_name}-${var.environment}-subnet"
  prohibit_public_ip  = false
  route_table_id      = oci_core_vcn.this[0].default_route_table_id

  freeform_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security List: equivalent to AWS security group rules
resource "oci_core_security_list" "this" {
  count          = var.oci_enabled ? 1 : 0
  compartment_id = var.oci_compartment
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.project_name}-${var.environment}-sl"

  # SSH ingress
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP ingress
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS ingress
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # All egress
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  freeform_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
