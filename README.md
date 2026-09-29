# OCI + AWS Dual-Cloud IaC Patterns

> Terraform reference modules exploring consistent network and compute provisioning across AWS and OCI.

Built to solve a real problem: when an organization runs multiple clouds ( by compliance requirement, contract obligation, or strategic choice ), the infrastructure code usually forks into separate codebases that drift apart. This project demonstrates the alternative: one abstraction layer with cloud-specific implementations underneath.

> **Note**: These are reference implementations, not production deployments. No live cloud deployment has been validated.

## Why This Exists

Most multi-cloud Terraform projects fall into one of two traps:

1. **Copy-paste divergence**: two separate codebases, one per cloud. They start identical and drift until nobody can tell you why AWS and OCI differ.
2. **Premature abstraction**: an over-engineered "cloud-agnostic" layer that hides so much it becomes unusable for real workloads.

This project takes a middle path: define the infrastructure contract ( "I need a network, a compute instance, and security rules" ), implement it per-cloud, and expose the same variables and outputs regardless of which cloud is active.

```
                    +-----------------+
                    |  Root Module    |
                    |  (main.tf)      |
                    +--------+--------+
                             |
              +--------------+--------------+
              |                             |
    +---------+---------+         +---------+---------+
    |  Network Module   |         |  Compute Module   |
    |  (VPC / VCN)      |         |  (EC2 / OCI VM)   |
    +---------+---------+         +---------+---------+
              |                             |
    +---------+---------+         +---------+---------+
    |  AWS Provider     |         |  AWS Provider     |
    |  aws_vpc          |         |  aws_instance     |
    |  aws_subnet       |         |                   |
    |  aws_sec_group    |         |                   |
    +-------------------+         +-------------------+
              |
    +---------+---------+
    |  OCI Provider     |
    |  oci_core_vcn     |         +---------+---------+
    |  oci_core_subnet  |         |  OCI Provider     |
    |  oci_sec_list     |         |  oci_core_instance|
    +-------------------+         +-------------------+
```

## Key Design Decisions

### 1. Independent CIDRs, Consistent Interface

Each cloud now uses a dedicated CIDR range to prevent IP overlap in dual-cloud deployments. AWS uses `vpc_cidr` and `subnet_cidr`, while OCI uses `oci_vpc_cidr` and `oci_subnet_cidr`. The module interface remains consistent, but the underlying network addressing is independent.

### 2. Count-Based Cloud Toggle

Each resource uses `count = var.aws_enabled ? 1 : 0` or `count = var.oci_enabled ? 1 : 0`. This lets you deploy to one cloud, both clouds, or neither ( dry run ) by flipping booleans. No provider configuration errors when a cloud is disabled.

### 3. Normalized Outputs

The module outputs use the same naming convention regardless of cloud:
- `aws_vpc_id` / `oci_vcn_id` ( not `vpc_id` and `vcn_id` with different semantics )
- `aws_subnet_id` / `oci_subnet_id`
- `aws_instance_public_ips` / `oci_instance_public_ips`

Consumers can write logic like:

```hcl
locals {
  all_instances = concat(
    module.compute.aws_instance_public_ips,
    module.compute.oci_instance_public_ips
  )
}
```

### 4. OCI-Specific Patterns

- **Regional subnets**: OCI subnets span all availability domains ( unlike AWS AZ-specific subnets ). The module respects this.
- **Compartment-based isolation**: OCI resources are placed in a specified compartment ( not an account boundary like AWS ).
- **Flex shapes**: OCI's Ampere A1 and E-series Flex shapes allow configurable OCPUs and memory. The module defaults to an Always Free-eligible `VM.Standard.A1.Flex` shape and exposes `oci_ocpus` and `oci_memory_gb` variables.
- **Always Free eligible**: Default shape and OCPU/memory settings fit within OCI's Always Free tier for Ampere A1 instances.

## Quick Start

### AWS Only

```bash
cd examples/aws-only
terraform init
terraform plan
terraform apply
```

### OCI Only

```bash
# Set OCI credentials via environment variables or terraform.tfvars
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1....."
export TF_VAR_oci_user_ocid="ocid1.user.oc1....."
export TF_VAR_oci_fingerprint="aa:bb:cc:..."
export TF_VAR_oci_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1....."
export TF_VAR_oci_ssh_public_key="ssh-rsa AAAA..."

cd examples/oci-only
terraform init
terraform plan
terraform apply
```

### Dual-Cloud ( AWS + OCI )

```bash
# Set both AWS and OCI credentials
export AWS_REGION=us-west-2
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1....."
# ... ( same as OCI-only above )

cd examples/dual-cloud
terraform init
terraform plan
terraform apply
```

## Module Structure

```
.
+-- main.tf              # Root module: calls network + compute modules
+-- variables.tf         # Root variables (cloud toggle, CIDR, instance config)
+-- outputs.tf           # Normalized outputs for both clouds
+-- providers.tf         # AWS + OCI provider configuration
+-- modules/
|   +-- network/
|   |   +-- main.tf      # VPC (AWS) + VCN (OCI) + subnets + gateways + security
|   |   +-- variables.tf
|   |   +-- outputs.tf
|   +-- compute/
|       +-- main.tf      # EC2 (AWS) + compute instances (OCI)
|       +-- variables.tf
|       +-- outputs.tf
+-- examples/
    +-- aws-only/        # AWS-only deployment
    +-- oci-only/        # OCI-only deployment
    +-- dual-cloud/      # Both clouds simultaneously
```

## AWS vs OCI: What This Project Handles

| Concern | AWS | OCI | How This Module Handles It |
|---------|-----|-----|---------------------------|
| Network boundary | VPC | VCN | Independent `vpc_cidr` and `oci_vpc_cidr` variables |
| Subnet scope | AZ-specific | Regional (all ADs) | Module respects OCI's regional model |
| Internet access | Internet Gateway | Internet Gateway | Both provisioned identically |
| Security rules | Security Group | Security List | Same port definitions (22, 80, 443), different syntax |
| Compute | EC2 instance | oci_core_instance | Same `instance_count`, different shape system |
| Sizing | Instance type (fixed) | Flex shape (configurable) | OCI exposes `ocpus` + `memory_gb` variables |
| Isolation | Account boundary | Compartment | OCI requires `compartment_ocid` variable |
| Image lookup | AMI (by name filter) | Image OCID (by OS filter) | Both auto-resolved when left empty |
| Tags | Resource tags | Freeform tags | Both applied with Environment/Project/ManagedBy |

## What I'd Add Next

- **Load balancer module**: AWS ALB + OCI Load Balancer behind the same interface
- **Object storage module**: S3 + OCI Object Storage
- **Database module**: RDS + OCI Autonomous Database
- **Cross-cloud connectivity**: VPN or FastConnect + Direct Connect peering
- **Cost estimation**: `terraform plan` + Infracost for dual-cloud cost comparison
- **Policy as code**: Sentinel/OPA policies enforcing consistent tagging across clouds

## Context

This pattern was distilled from multi-cloud infrastructure work across defense, media, and cloud consulting engagements.

## License

MIT
