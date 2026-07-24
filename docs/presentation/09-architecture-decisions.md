# 09 – Architecture Decisions

---

# Purpose

Every architecture represents a series of engineering decisions.

The purpose of this chapter is to document the key architectural decisions made during the design of the AWS Isolated Recovery Environment (IRE), the alternatives that were evaluated, and the rationale behind the final selections.

Recording these decisions provides long-term architectural consistency, simplifies future design reviews, and helps ensure that future enhancements align with the original design intent.

---

# Decision-Making Principles

Throughout the design process, every architectural decision was evaluated against five criteria:

- Security
- Operational Simplicity
- Recoverability
- Scalability
- Governance

Whenever two options offered similar functionality, preference was given to the design that reduced operational risk while maintaining strong security boundaries.

---

# Decision 1 – Trust Boundary Architecture

## Decision

Design the recovery environment using independent trust boundaries rather than a flat network.

## Options Considered

| Option | Outcome |
|---------|---------|
| Single Trust Boundary | Rejected |
| Multiple Independent Trust Boundaries | Selected |

## Rationale

Modern cyber recovery requires isolation between administrative access, recovery execution, network inspection, and protected recovery assets.

Separating these responsibilities significantly reduces the blast radius of a compromise.

---

# Decision 2 – Three-VPC Architecture

## Decision

Adopt a three-VPC architecture consisting of:

- Recovery Access VPC
- Core Recovery VPC
- Protected Data VPC

## Alternatives

### Single VPC

Advantages

- Simpler deployment
- Lower networking cost

Disadvantages

- Shared trust boundary
- Greater lateral movement
- Limited security separation

Decision

Rejected

---

### Five-VPC Architecture

Advantages

- Maximum isolation
- Highly granular segmentation

Disadvantages

- Operational complexity
- Additional Transit Gateway routing
- Higher cost
- More administration
- Longer recovery time

Decision

Rejected

---

### Three-VPC Architecture

Advantages

- Strong security isolation
- Manageable operational complexity
- Clear separation of duties
- Easier governance
- Better scalability

Decision

Selected

---

# Decision 3 – AWS Managed Microsoft AD

## Decision

Deploy an independent AWS Managed Microsoft Active Directory inside the Core Recovery VPC.

## Alternatives

### Production Active Directory

Rejected because:

- Production identities may be compromised.
- Recovery becomes dependent on production availability.
- Attackers could reuse compromised credentials.

### AWS Managed Microsoft AD

Selected because:

- Independent identity services
- Managed by AWS
- Multi-AZ deployment
- Reduced administrative overhead
- Supports enterprise authentication during recovery

---

# Decision 4 – Infrastructure as Code

## Decision

Provision recovery infrastructure using Terraform.

## Alternatives

### Manual Infrastructure Deployment

Rejected because:

- Slow
- Error-prone
- Difficult to audit
- Difficult to repeat consistently

### Terraform

Selected because:

- Version control
- Repeatability
- Automation
- Standardization
- Faster recovery

---

# Decision 5 – Configuration Automation

## Decision

Use Red Hat Ansible Automation Platform for operating system and application configuration.

## Alternatives

### Manual Configuration

Rejected because:

- Inconsistent
- Time-consuming
- Difficult to validate
- High operational risk

### Red Hat Ansible Automation Platform

Selected because:

- Repeatable configuration
- Enterprise automation
- Idempotent execution
- Integration with Infrastructure as Code

---

# Decision 6 – Transit Gateway

## Decision

Use AWS Transit Gateway as the central routing hub.

## Alternatives

### VPC Peering

Rejected because:

- Poor scalability
- Complex routing
- Difficult governance
- Increasing operational complexity as VPC count grows

### Transit Gateway

Selected because:

- Hub-and-spoke architecture
- Simplified routing
- Centralized connectivity
- Easier expansion

---

# Decision 7 – Central Inspection Hub

## Decision

Inspect all inter-VPC traffic using a centralized inspection layer.

## Alternatives

### Distributed Firewalls

Rejected because:

- Duplicate configuration
- Inconsistent policies
- Increased operational effort

### Central Inspection Hub

Selected because:

- Consistent policy enforcement
- Simplified governance
- Centralized visibility
- Easier auditing

---

# Decision 8 – Immutable Recovery Storage

## Decision

Protect recovery artifacts using Amazon S3 Object Lock.

## Alternatives

### Standard Amazon S3

Rejected because:

- Objects can be deleted
- Objects can be overwritten
- Increased ransomware risk

### Amazon S3 Object Lock

Selected because:

- Write Once Read Many (WORM)
- Protection against deletion
- Protection against modification
- Supports compliance requirements

---

# Decision 9 – Metadata Repository

## Decision

Store recovery metadata separately using Amazon DynamoDB.

## Alternatives

### Metadata Stored Inside Backup Files

Rejected because:

- Slow searching
- Limited reporting
- Difficult automation

### Amazon DynamoDB

Selected because:

- Fast lookups
- Structured metadata
- Automation support
- Scalable architecture

---

# Decision 10 – Private Administrative Access

## Decision

Use AWS Client VPN together with AWS Systems Manager Session Manager.

## Alternatives

### Direct SSH

Rejected because:

- Public IP addresses
- SSH key management
- Larger attack surface

### Bastion Hosts

Rejected because:

- Additional infrastructure
- Patch management
- Operational overhead

### VPN + Session Manager

Selected because:

- Private administration
- No inbound SSH or RDP
- Comprehensive auditing
- Managed AWS services

---

# Decision 11 – Recovery Validation Before Cutover

## Decision

Require technical and business validation before production cutover.

## Alternatives

### Immediate Production Cutover

Rejected because:

- Increased operational risk
- Potential malware reintroduction
- No business verification

### Multi-Stage Validation

Selected because:

- Security verification
- Business approval
- Reduced operational risk
- Greater confidence in recovered systems

---

# Decision Summary

| Decision | Selected Approach |
|----------|-------------------|
| Network Segmentation | Three independent trust boundaries |
| Identity | AWS Managed Microsoft AD |
| Infrastructure Provisioning | Terraform |
| Configuration Management | Red Hat Ansible Automation Platform |
| Inter-VPC Connectivity | AWS Transit Gateway |
| Traffic Inspection | Central Inspection Hub |
| Recovery Storage | Amazon S3 Object Lock |
| Metadata | Amazon DynamoDB |
| Administration | AWS Client VPN + Session Manager |
| Validation | Technical and business approval |

---

# Architectural Trade-offs

Every architectural decision involved trade-offs.

| Benefit | Trade-off |
|---------|-----------|
| Strong isolation | Additional networking components |
| Independent identity | Separate identity administration |
| Immutable storage | Additional governance processes |
| Centralized inspection | Slightly more complex routing |
| Infrastructure as Code | Initial development effort |
| Automated recovery | Ongoing maintenance of automation |

These trade-offs were considered acceptable because they significantly improve the security and reliability of cyber recovery.

---

# Alignment with AWS Well-Architected Framework

| Pillar | Design Decisions Supporting the Pillar |
|---------|----------------------------------------|
| Security | Trust boundaries, Zero Trust, Object Lock, centralized inspection |
| Reliability | Multi-AZ services, Infrastructure as Code, automation |
| Operational Excellence | Terraform, Ansible, standardized workflows |
| Performance Efficiency | Managed AWS services, scalable networking |
| Cost Optimization | Shared security services, reusable automation components |

---

# Future Considerations

The architecture has been designed to accommodate future enhancements, including:

- Additional Recovery Access VPCs for regional expansion.
- Multi-region recovery repositories.
- Additional security inspection capabilities.
- Enhanced automation workflows.
- Expanded compliance reporting.
- Automated recovery testing and validation.

These enhancements can be introduced without fundamentally changing the core trust boundary architecture.

---

# Architecture Decision Record (ADR)

Future architectural changes should be documented using an Architecture Decision Record (ADR).

Each ADR should include:

- Decision identifier
- Date
- Business context
- Alternatives considered
- Final decision
- Rationale
- Impact assessment
- Approval authority

Maintaining ADRs ensures that future design changes remain traceable and aligned with the original architecture.

---

# Key Takeaways

- Every major component of the AWS Isolated Recovery Environment was selected through a structured evaluation process.
- Security, recoverability, operational simplicity, scalability, and governance were the primary decision criteria.
- The selected three-VPC architecture provides the best balance between strong isolation and operational manageability.
- Infrastructure as Code, automation, immutable storage, centralized inspection, and independent identity services collectively establish a secure and resilient cyber recovery platform.
- Documenting architectural decisions ensures long-term consistency, simplifies governance, and supports future evolution of the recovery environment.

> **A well-designed architecture is defined not only by the technologies it uses, but by the engineering decisions that explain why those technologies were chosen over every alternative.**
