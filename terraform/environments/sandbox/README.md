# Sandbox Environment

Three-VPC IRE topology (landing zone, core recovery, protected data) connected
via Transit Gateway with **segmented route tables**:

- Landing zone reaches core recovery and protected data.
- Core recovery and protected data reach the landing zone only.
- Core ↔ protected is explicitly blackholed at the TGW.

> **Deviation from the IRE HLD:** the production design has no Internet
> Gateway or NAT anywhere (access is via Client VPN only). This sandbox
> intentionally includes an IGW + public subnets in the landing zone for
> low-cost testing. Remove `public_subnets` to match the HLD.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init          # backend is defined in backend.tf
terraform plan
```

Traffic destined for the inspection path (GWLB + Network Firewall) will be
introduced once the `network-firewall` module lands; at that point the
propagations here change to route spoke↔spoke traffic through the firewall
route table instead of blackholing.
