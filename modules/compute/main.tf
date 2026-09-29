# ============================================================
# Compute Abstraction Module
# Provisions equivalent compute instances in AWS (EC2) and OCI
# Same interface, different implementations per cloud.
# ============================================================

# -----------------------------------------------------------
# AWS: EC2 instances
# -----------------------------------------------------------

# Data source for latest Amazon Linux 2 AMI (when ami_id not specified)
data "aws_ami" "amazon_linux" {
  count       = var.aws_enabled && var.aws_ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "this" {
  count                       = var.aws_enabled ? var.instance_count : 0
  ami                         = var.aws_ami_id != "" ? var.aws_ami_id : data.aws_ami.amazon_linux[0].id
  instance_type               = var.aws_instance_type
  subnet_id                   = var.aws_subnet_id
  vpc_security_group_ids      = [var.aws_security_group]
  associate_public_ip_address = true

  # Only set key_name if a key pair exists (simplified: use inline key)
  # In production, reference a pre-created key pair
  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------
# OCI: Compute instances
# -----------------------------------------------------------

# Data source for latest Oracle Linux 8 image (when image_ocid not specified)
data "oci_core_images" "ol8" {
  count                     = var.oci_enabled && var.oci_image_ocid == "" ? 1 : 0
  compartment_id            = var.oci_compartment
  operating_system          = "Oracle Linux"
  operating_system_version  = "8"
  shape                     = var.oci_instance_shape
  sort_by                   = "TIMECREATED"
  sort_order                = "DESC"
}

resource "oci_core_instance" "this" {
  count               = var.oci_enabled ? var.instance_count : 0
  compartment_id      = var.oci_compartment
  availability_domain = data.oci_identity_availability_domains.ads[0].availability_domains[0].name
  shape               = var.oci_instance_shape
  display_name        = "${var.project_name}-${var.environment}-instance-${count.index + 1}"

  shape_config {
    ocpus         = var.oci_ocpus
    memory_in_gbs = var.oci_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = var.oci_image_ocid != "" ? var.oci_image_ocid : data.oci_core_images.ol8[0].images[0].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = var.oci_subnet_id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.oci_ssh_public_key
  }

  freeform_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Availability domains lookup (OCI)
data "oci_identity_availability_domains" "ads" {
  count          = var.oci_enabled ? 1 : 0
  compartment_id = var.oci_compartment
}
