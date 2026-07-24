# 03 – Recovery Access VPC

---

# Purpose

The Recovery Access VPC is the secure administrative gateway into the AWS Isolated Recovery Environment (IRE).

Its purpose is **not** to perform recovery operations.

Its responsibility is to establish a trusted administrative session before any interaction with the recovery platform occurs.

This VPC forms the second trust boundary within the architecture and separates human administrative access from the automation platform responsible for executing recovery activities.

It answers one question:

> **Can this administrator safely enter the recovery environment?**

---

# Business Problem

Administrative access represents one of the highest-risk attack vectors during a cyber incident.

Even after an administrator has successfully authenticated, allowing direct access to recovery workloads creates unnecessary exposure.

Administrators use laptops, browsers, VPN clients, and management tools that may themselves become compromised.

The architecture therefore introduces a dedicated Recovery Access VPC to isolate human administrative activities from the systems responsible for rebuilding infrastructure and restoring business services.

By separating administrative ingress from recovery execution, the environment significantly reduces the attack surface and limits the blast radius of a compromised endpoint.

---

# Design Objectives

The Recovery Access VPC has been designed to achieve the following objectives:

- Provide a secure administrative landing zone.
- Isolate human administrators from recovery workloads.
- Eliminate direct internet management of AWS resources.
- Support private communication with AWS managed services.
- Centralize privileged access logging.
- Maintain high availability during cyber recovery.
- Enforce least privilege through network segmentation.

---

# Presentation Script

The Recovery Access VPC serves as the secure administrative gateway into the Isolated Recovery Environment.

Its primary responsibility is **not workload recovery**.

Its responsibility is to establish a trusted administrative session before any interaction with the recovery platform occurs.

Think of this VPC as the airport security checkpoint.

Before passengers can board an aircraft, their identity is verified, baggage is screened, and authorization is confirmed.

Similarly, every administrator must pass through this trust boundary before accessing the recovery platform.

---

# Why Is It Separate from the Core Recovery VPC?

Administrative access and recovery execution have fundamentally different security requirements.

Human administrators introduce a higher level of operational risk than automated recovery systems.

Separating these functions into independent VPCs provides several advantages:

- Reduces attack surface
- Limits blast radius
- Separates duties
- Simplifies network policy
- Improves governance
- Strengthens Zero Trust

Even if an administrator's workstation becomes compromised after authentication, an attacker must still cross additional trust boundaries before reaching recovery workloads or protected recovery data.

---

# High-Level Architecture

```
                Internet
                    │
                    ▼
            AWS Client VPN
                    │
                    ▼
            Public Subnets
                    │
                    ▼
        Private Administrative Subnets
                    │
      ┌─────────────┼─────────────┐
      ▼             ▼             ▼
 Session Manager  Secrets Mgr   EC2 Messages
      │
      ▼
   Core Recovery VPC
```

---

# Components

## Public Subnets

### Purpose

The public subnets host the AWS Client VPN endpoints.

These subnets provide the controlled ingress point for authenticated recovery administrators.

No application workloads are deployed within these public subnets.

No recovery services execute here.

### Why Public?

The VPN endpoint must be reachable by authorized administrators connecting from outside AWS.

Public accessibility applies only to the VPN endpoint.

It does **not** mean recovery servers or administrative workstations are internet-accessible.

There are:

- No public EC2 instances
- No public application servers
- No public databases

Only the managed VPN endpoint accepts inbound administrative connections.

---

## Private Administrative Subnets

Following successful authentication, administrators enter hardened private administrative subnets.

These subnets contain secure administrative workstations used exclusively during recovery activities.

Recovery infrastructure is never managed directly from an administrator's laptop.

Instead, administration occurs through managed recovery workstations inside the trusted environment.

### Why Dedicated Administrative Workstations?

Dedicated workstations provide:

- Consistent tooling
- Controlled software configuration
- Reduced dependency on administrator laptops
- Centralized monitoring
- Simplified auditing

This approach significantly reduces the likelihood that malware residing on an administrator endpoint can directly interact with recovery infrastructure.

---

## Break-Glass Workstation

The Break-Glass Workstation exists solely for emergency situations.

Examples include:

- Enterprise identity compromise
- VPN authentication failure
- Identity provider outage
- Catastrophic cyber incident

Access to this workstation is tightly controlled.

Typical controls include:

- Executive approval
- Security approval
- Full session recording
- Enhanced auditing
- Time-limited access

---

# Interface VPC Endpoints

The Recovery Access VPC communicates with AWS managed services through Interface VPC Endpoints.

This enables private communication without requiring Internet Gateways or NAT Gateways.

## Systems Manager Endpoint

Provides private communication between managed instances and AWS Systems Manager.

Benefits include:

- No internet dependency
- Secure management channel
- Reduced attack surface

---

## EC2 Messages Endpoint

Supports secure message exchange between Systems Manager and managed EC2 instances.

This service enables command delivery and operational communication without exposing management ports.

---

## SSM Messages Endpoint

Maintains secure interactive shell sessions used by AWS Systems Manager Session Manager.

Administrators can securely manage EC2 instances without exposing SSH or RDP to the network.

---

## Secrets Manager Endpoint

Allows workloads to retrieve:

- Passwords
- Certificates
- API Keys
- Database credentials

All communication remains on the AWS private network.

---

# Security and Monitoring

Administrative actions generate comprehensive audit evidence.

## AWS CloudTrail

CloudTrail records:

- AWS API calls
- IAM changes
- EC2 lifecycle events
- Resource modifications
- Administrative actions

CloudTrail answers questions such as:

- Who created an EC2 instance?
- Who deleted an S3 bucket?
- Who modified IAM policies?

---

## Amazon GuardDuty

GuardDuty continuously analyzes:

- CloudTrail logs
- DNS activity
- VPC Flow Logs

It detects suspicious behavior including:

- Credential misuse
- Unauthorized API activity
- Malicious network communication
- Threat intelligence matches

---

## VPC Flow Logs

VPC Flow Logs capture network traffic metadata.

They provide visibility into:

- Allowed traffic
- Rejected traffic
- Source and destination addresses
- Network troubleshooting
- Forensic investigations

---

## CloudTrail vs CloudWatch

These services serve different purposes.

| Service | Primary Function |
|----------|------------------|
| CloudTrail | Audits people and API activity |
| CloudWatch | Monitors systems, metrics, logs, and health |

CloudTrail answers:

> **Who changed something?**

CloudWatch answers:

> **Is the system healthy?**

---

# Network Design Decisions

## CIDR Allocation

The Recovery Access VPC uses a /22 CIDR block.

This provides approximately 1,024 private IP addresses.

Reasons include:

- Future expansion
- Additional Availability Zones
- Growth of Interface Endpoints
- Administrative subnet separation
- Scalability

---

## Multi-Availability Zone Deployment

Administrative access must remain available during infrastructure failures.

Critical components are deployed across multiple Availability Zones to eliminate single points of failure.

If one Availability Zone becomes unavailable, administrative operations continue through the remaining zone.

---

## Security Groups

Every component within the Recovery Access VPC is protected using dedicated least-privilege Security Groups.

These include:

- VPN endpoints
- Administrative workstations
- Interface Endpoints

Communication is explicitly permitted rather than implicitly trusted.

---

## Route Tables

Dedicated route tables ensure administrative traffic follows only approved network paths.

There is intentionally **no direct routing** from the Recovery Access VPC to the Protected Data VPC.

All communication toward sensitive resources must traverse the architecture's defined trust boundaries.

---

# Why Doesn't This VPC Contain Recovery Workloads?

The Recovery Access VPC intentionally excludes:

- Application servers
- Databases
- Terraform
- Ansible Automation Platform
- Recovery repositories

These components belong elsewhere because they serve different responsibilities.

| Component | Correct Location | Reason |
|-----------|------------------|--------|
| Applications | Core Recovery VPC | Recovery execution |
| Terraform | Core Recovery VPC | Infrastructure orchestration |
| Ansible | Core Recovery VPC | Configuration automation |
| Databases | Protected Data VPC | Persistent business data |
| Immutable Recovery Storage | Protected Data VPC | Data protection |

This separation follows the Single Responsibility Principle and strengthens network segmentation.

---

# Architecture Decision

The Recovery Access VPC exists solely to provide a secure administrative landing zone.

It deliberately avoids performing recovery operations.

Separating administrative ingress from recovery execution enables:

- Stronger Zero Trust implementation
- Reduced attack surface
- Improved governance
- Better operational control
- Simplified auditing

---

# Alternatives Considered

| Alternative | Reason Rejected |
|-------------|-----------------|
| Single VPC | Administrative and recovery traffic share the same trust boundary |
| Direct administrative access to Core Recovery | Increased attack surface |
| Public management interfaces | Public exposure and higher operational risk |
| Internet-based AWS service access | Reduced security and greater dependency on internet connectivity |

---

# AWS Well-Architected Alignment

| Pillar | Implementation |
|---------|----------------|
| Security | Private administration, Interface Endpoints, Security Groups, CloudTrail |
| Reliability | Multi-AZ deployment and managed AWS services |
| Operational Excellence | Centralized administration and auditing |
| Performance Efficiency | Private AWS networking and managed endpoints |
| Cost Optimization | Eliminates unnecessary bastion infrastructure and minimizes operational overhead |

---

# Risks Mitigated

| Risk | Mitigation |
|------|------------|
| Compromised administrator endpoint | Administrative isolation and trust boundaries |
| Internet-based attacks | No public management interfaces |
| Credential misuse | Centralized authentication and monitoring |
| Unauthorized AWS changes | CloudTrail and GuardDuty |
| Lateral movement | Segmented VPC design and controlled routing |

---

# Key Takeaways

- The Recovery Access VPC is **not** a recovery platform.
- It exists to establish a trusted administrative session before recovery operations begin.
- Human administrative access is isolated from automation and protected recovery assets.
- Private Interface VPC Endpoints eliminate the need for internet-based management.
- Comprehensive logging and monitoring provide complete auditability of privileged activity.
- This trust boundary answers one question:

> **Can this administrator safely enter the recovery environment?**

Only after that question has been answered does the administrator progress to the Core Recovery VPC, where recovery orchestration and automation begin.
