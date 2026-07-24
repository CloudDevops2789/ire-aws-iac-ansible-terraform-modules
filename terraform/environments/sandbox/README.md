# Sandbox Environment

Three-VPC IRE topology (landing zone, core recovery, protected data)
connected via Transit Gateway.

> **Deviation from the IRE HLD:** the production design has no Internet
> Gateway or NAT anywhere (access is via Client VPN only). This sandbox
> intentionally includes an IGW + public subnets in the landing zone for
> low-cost testing. Remove `public_subnets` to match the HLD.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```
