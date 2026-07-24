# 06 – Protected Data VPC

---

# Purpose

The Protected Data VPC is the most secure trust boundary within the AWS Isolated Recovery Environment (IRE).

Its purpose is to safeguard the organization's most valuable recovery assets, including immutable backups, recovery repositories, infrastructure definitions, application artifacts, and operational metadata.

Unlike the Core Recovery VPC, which executes recovery activities, the Protected Data VPC exists solely to preserve trusted recovery assets and ensure they remain available, authentic, and unaltered during a cyber incident.

This trust boundary answers one question:

> **What are we protecting?**

---

# Business Problem

Modern ransomware attacks rarely stop at encrypting production systems.

Attackers increasingly target:

- Backup repositories
- Recovery environments
- Infrastructure definitions
- Administrative credentials
- Configuration repositories
- Software repositories

If recovery assets themselves become encrypted, deleted, or modified, the organization may have no trusted starting point for recovery.

The recovery environment therefore requires an isolated vault where critical recovery assets remain protected, immutable, and independently governed.

The Protected Data VPC fulfills that responsibility.

---

# Design Objectives

The Protected Data VPC has been designed to:

- Protect immutable recovery artifacts.
- Isolate recovery data from operational workloads.
- Prevent unauthorized modification or deletion.
- Store trusted infrastructure and application assets.
- Maintain independent encryption.
- Provide centralized metadata management.
- Support long-term retention and governance.
- Enable trusted recovery after a cyber incident.

---

# Presentation Script

The Protected Data VPC represents the final trust boundary within the recovery architecture.

Everything required to rebuild the enterprise ultimately originates from this environment.

If the Recovery Access VPC establishes trust and the Core Recovery VPC performs recovery, the Protected Data VPC preserves the trusted assets that make recovery possible.

Think of this VPC as a secure vault.

Only authorized recovery processes may retrieve approved assets.

No workload can modify protected recovery artifacts without following defined governance controls.

---

# High-Level Architecture

```
                  Central Inspection Hub
                           │
                           ▼
                 Protected Data VPC
                           │
      ┌────────────────────┼────────────────────┐
      ▼                    ▼                    ▼
 Immutable Storage     Recovery Repository   Metadata Store
      │                    │                    │
      ▼                    ▼                    ▼
  Amazon S3          Terraform Modules     Amazon DynamoDB
  Object Lock        Golden AMIs           Recovery Inventory
                     Ansible Collections
                     Container Images
```

---

# Recovery Repository

The Recovery Repository contains every trusted artifact required to rebuild the recovery environment.

Typical contents include:

- Golden AMIs
- Terraform Modules
- Ansible Playbooks
- Ansible Collections
- Container Images
- Recovery Runbooks
- Software Packages
- Configuration Templates

Rather than downloading software during an emergency, all approved recovery assets are maintained within the isolated repository.

---

# Immutable Storage

One of the primary responsibilities of this VPC is maintaining immutable recovery data.

Recovery artifacts must not be modified after they have been approved.

Immutability ensures that attackers cannot encrypt, overwrite, or delete critical recovery assets.

---

# Amazon S3 with Object Lock

Amazon S3 Object Lock provides Write Once Read Many (WORM) protection.

Once an object has been written and protected by an Object Lock retention policy, it cannot be modified or deleted until the retention period expires.

Typical protected assets include:

- Active Directory backups
- Database backups
- File system backups
- Recovery packages
- Configuration exports
- Recovery evidence

Object Lock provides confidence that recovery artifacts remain identical to the versions originally approved.

---

# Recovery Metadata

Recovery is not simply about storing files.

The organization must also know:

- Which backup belongs to which application.
- Recovery timestamps.
- Backup validation status.
- Encryption state.
- Retention period.
- Recovery priority.
- Recovery owner.

This information is maintained separately from the recovery artifacts themselves.

---

# Amazon DynamoDB

Amazon DynamoDB stores operational metadata describing recovery assets.

Example metadata includes:

- Repository identifier
- Application name
- Environment
- Backup date
- Recovery point objective (RPO)
- Retention status
- Validation result
- Checksum
- Encryption status

Separating metadata from storage simplifies governance and enables rapid lookup during recovery.

---

# Encryption

All recovery assets are encrypted both in transit and at rest.

AWS Key Management Service (KMS) is used to manage encryption keys protecting:

- Amazon S3
- Amazon DynamoDB
- EBS snapshots
- Recovery repositories

Key access follows least privilege and is restricted to approved recovery services.

---

# Data Integrity

Recovery assets are validated before being accepted into the repository.

Typical validation includes:

- SHA-256 checksum verification
- Digital signature validation
- Backup completion verification
- Integrity testing
- Malware scanning (where applicable)

Only validated artifacts are designated as trusted recovery assets.

---

# Repository Governance

Recovery assets follow a controlled lifecycle.

1. Artifact created.
2. Artifact validated.
3. Metadata recorded.
4. Artifact approved.
5. Object Lock applied.
6. Artifact becomes available for recovery.

This governance process ensures that only trusted artifacts are available during recovery operations.

---

# Access Control

Direct administrator access to recovery assets is intentionally restricted.

Access is typically granted only to:

- Recovery automation
- Approved validation services
- Authorized break-glass administrators

Application workloads cannot directly modify recovery repositories.

---

# Network Isolation

The Protected Data VPC has no direct administrative ingress.

All communication must traverse:

```
Recovery Access VPC
        │
        ▼
Core Recovery VPC
        │
        ▼
Central Inspection Hub
        │
        ▼
Protected Data VPC
```

No workload bypasses this sequence.

---

# High Availability

Recovery repositories are deployed using highly durable AWS managed storage services.

Critical metadata is replicated across Availability Zones.

Recovery artifacts remain available even if an Availability Zone becomes unavailable.

---

# Design Decisions

## Why Separate the Protected Data VPC?

Recovery compute changes frequently.

Recovery data should not.

Separating data from compute reduces the likelihood that compromised workloads can directly modify protected recovery assets.

---

## Why Object Lock?

Traditional backups can still be deleted.

Object Lock prevents deletion during the configured retention period.

This significantly improves resilience against ransomware.

---

## Why Separate Metadata?

Searching millions of backup objects is inefficient.

Maintaining metadata independently enables rapid recovery planning and automation.

---

# Alternatives Considered

| Alternative | Reason Rejected |
|-------------|-----------------|
| Store recovery data inside Core Recovery VPC | Increased attack surface |
| Traditional S3 buckets without Object Lock | Objects remain vulnerable to deletion or modification |
| Store metadata inside backup files | Poor searchability and governance |
| Shared repositories with production | Production compromise could impact recovery assets |

---

# AWS Well-Architected Alignment

| Pillar | Implementation |
|---------|----------------|
| Security | Object Lock, KMS encryption, least privilege |
| Reliability | Highly durable managed storage and Multi-AZ services |
| Operational Excellence | Metadata-driven automation and governance |
| Performance Efficiency | Fast metadata lookup through DynamoDB |
| Cost Optimization | Managed services with lifecycle and retention policies |

---

# Risks Mitigated

| Risk | Mitigation |
|------|------------|
| Backup deletion | Amazon S3 Object Lock |
| Backup modification | Immutable storage |
| Metadata loss | Amazon DynamoDB |
| Unauthorized access | IAM and network segmentation |
| Compromised recovery assets | Validation, checksums, encryption, governance |

---

# Architecture Decision

The Protected Data VPC intentionally separates recovery assets from operational recovery systems.

Recovery infrastructure may be rebuilt repeatedly.

Recovery data must remain stable, trusted, and protected.

This separation reduces operational risk while ensuring recovery always begins from approved and immutable artifacts.

---

# Architecture Review Questions

During architecture reviews, common questions include:

- Why are recovery repositories isolated from recovery compute?
- How is Object Lock governance managed?
- How are KMS keys protected?
- How are recovery artifacts validated before use?
- How are old recovery artifacts retired?
- What happens if DynamoDB metadata becomes unavailable?
- How are integrity checks performed?
- Can recovery proceed if an artifact fails validation?

These questions should be addressed through operational procedures and governance documentation.

---

# Key Takeaways

- The Protected Data VPC is the secure vault of the AWS Isolated Recovery Environment.
- It stores immutable recovery artifacts, trusted software repositories, infrastructure definitions, and operational metadata.
- Amazon S3 Object Lock protects recovery assets from modification and deletion.
- Amazon DynamoDB provides rapid metadata lookup for recovery planning.
- AWS KMS protects recovery assets through centralized encryption key management.
- Network isolation ensures recovery assets are never directly exposed to administrators or workloads.
- This trust boundary answers one question:

> **What are we protecting?**

By preserving trusted, immutable recovery assets within an isolated trust boundary, the Protected Data VPC provides the secure foundation upon which every successful cyber recovery operation depends.
