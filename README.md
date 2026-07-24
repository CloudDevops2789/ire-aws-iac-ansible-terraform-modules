
## Infrastructure Development Lifecycle

<img width="4562" height="250" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/fcc4aa99-7f4a-4fd6-ba95-050416844d9a" />



Every Terraform module follows this lifecycle from planning to deployment.



## Repository Architecture

<img width="2564" height="527" alt="mermaid-diagram (1)" src="https://github.com/user-attachments/assets/d19e40b4-41d0-494e-a7ec-88d8a2630791" />





## Module Development Lifecycle


<img width="4562" height="250" alt="mermaid-diagram (2)" src="https://github.com/user-attachments/assets/ebee1778-2a9d-413b-a111-0d9eeeb2e932" />


## Module Status


### Terraform modules

| Module | Status | Notes |
|---|---|---|
| `vpc` | Completed | Subnets, IGW (conditional), route tables |
| `transit-gateway` | Completed | Attachments, segmented route tables, propagations, static/blackhole routes |
| `s3-object-lock` | InProgeess | Backend bucket currently bootstrapped via Ansible |
| `network-firewall`, `client-vpn` | InProgeess | Inspection path per IRE HLD |
| `ec2`, `rds`, `efs` | InProgeess | |
| `iam`, `security-group` | InProgeess | |
| `guardduty`, `cloudtrail` | InProgeess | |

### Environments

| Environment | Status | Notes |
|---|---|---|
| `sandbox` | Completed | 3 VPCs + TGW with segmented routing (core ↔ protected blackholed) |
