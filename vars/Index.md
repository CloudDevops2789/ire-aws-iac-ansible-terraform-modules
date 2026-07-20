

# AWS Isolated Recovery Environment (IRE)

## Enterprise Architecture Design Guide

**Version:** 1.0

**Document Type:** High Level Design (HLD)

**Classification:** Internal Use Only

**Prepared By:** Infrastructure Engineering

---

# Executive Summary

Modern ransomware attacks no longer target only production workloads. They frequently compromise privileged identities, Active Directory, backup infrastructure, management servers, and recovery environments themselves. Recovering into an environment that shares the same trust boundaries as production significantly increases the risk of reinfection and operational failure.

The Fairview AWS Isolated Recovery Environment (IRE) has been designed to provide an independent, secure, and trusted recovery platform capable of restoring critical business services after a cyber incident.

Unlike a traditional Disaster Recovery (DR) environment, this architecture follows Zero Trust principles by separating administrative access, recovery orchestration, and protected recovery data into independent trust boundaries. Every administrator, workload, network connection, and recovery artifact must be authenticated, validated, inspected, and approved before participating in the recovery process.

Infrastructure provisioning is automated using Terraform, operating system and application configuration are automated using Red Hat Ansible Automation Platform, and recovery artifacts are protected using immutable storage and controlled governance workflows.

The result is an enterprise recovery platform that minimizes operational risk, limits ransomware propagation, improves auditability, and provides repeatable, validated recovery.

---

# Purpose

The purpose of this document is to describe the architecture, design decisions, security principles, operational workflows, and implementation approach for the AWS Isolated Recovery Environment (IRE).

This document serves as:

- Enterprise Architecture Design
- High-Level Design (HLD)
- Security Architecture Reference
- Cyber Recovery Design Guide
- Operational Knowledge Base
- Architecture Review Board Submission
- CISO Review Document

---

# Intended Audience

This document is intended for:

- Enterprise Architects
- AWS Solutions Architects
- Cloud Security Engineers
- Infrastructure Engineering Teams
- Disaster Recovery Teams
- Platform Engineering
- Cyber Recovery Teams
- Audit and Compliance Teams
- Executive Leadership

---

# Scope

This document covers:

- Administrative Access
- Recovery Access VPC
- Core Recovery VPC
- Central Inspection Hub
- Protected Data VPC
- Identity Strategy
- Automation Strategy
- Recovery Lifecycle
- Security Principles
- Design Decisions
- Governance
- Architecture Evolution

---

# Business Problem

Traditional Disaster Recovery environments assume the recovery platform itself remains trustworthy.

Modern ransomware attacks invalidate that assumption.

Threat actors commonly target:

- Active Directory
- Backup infrastructure
- Hypervisors
- Administrative credentials
- Recovery consoles
- Disaster Recovery environments

As a result, simply restoring workloads into another environment is no longer sufficient.

The recovery environment itself must remain isolated, independently trusted, and capable of validating recovery artifacts before restoration.

This architecture addresses that challenge.

---

# Design Objectives

The architecture has been designed around the following objectives.

## Security

- Zero Trust
- Least Privilege
- Independent Trust Boundaries
- Defense in Depth
- Immutable Recovery Assets

## Resilience

- Multi-AZ Deployment
- Independent Identity
- Independent DNS
- Automated Recovery
- Trusted Recovery Repository

## Operational Excellence

- Infrastructure as Code
- Configuration as Code
- Standardized Recovery
- Repeatable Processes
- Reduced Human Error

## Governance

- Auditability
- Approval Workflows
- Evidence Generation
- Security Monitoring
- Operational Visibility

---

# Architecture Philosophy

The Isolated Recovery Environment is organized around **trust boundaries**, not simply network segmentation.

Each boundary has a single responsibility:

| Trust Boundary | Responsibility |
|---------------|----------------|
| Administrative Access | Verify identity |
| Recovery Access VPC | Secure administrative ingress |
| Core Recovery VPC | Execute recovery operations |
| Central Inspection Hub | Inspect east-west traffic |
| Protected Data VPC | Protect recovery data |

Every communication between these boundaries is explicitly controlled.

Nothing is trusted by default.

---

# Architecture Evolution

The architecture evolved through several design iterations before arriving at the final three-VPC model.

## Phase 1 — Subnet-Based Isolation

### Advantages

- Simple implementation
- Lower operational complexity
- Minimal networking

### Limitations

- Shared trust boundary
- Large blast radius
- Easier lateral movement
- Difficult security separation

Decision:

❌ Rejected

---

## Phase 2 — Five-VPC Architecture

### Advantages

- Maximum isolation
- Strong separation
- Fine-grained control

### Limitations

- High operational complexity
- Excessive Transit Gateway routing
- Higher cost
- More operational overhead
- Longer recovery times

Decision:

❌ Rejected

---

## Phase 3 — Two-VPC Architecture

### Advantages

- Simpler routing
- Reduced networking complexity

### Limitations

- Administrative access and recovery operations share the same trust boundary
- Reduced separation of duties

Decision:

❌ Rejected

---

## Final Architecture — Three-VPC Model

The final architecture separates the environment into three independent trust boundaries.

| VPC | Responsibility |
|------|---------------|
| Recovery Access | Administrative ingress |
| Core Recovery | Recovery orchestration |
| Protected Data | Recovery assets |

This design provides the best balance between:

- Security
- Operational simplicity
- Recovery speed
- Governance
- Scalability

---

# Repository Structure

This documentation is organized as follows.

| Document | Description |
|-----------|-------------|
| README.md | Executive overview and architecture introduction |
| 02-administrative-access.md | Administrative Access Trust Boundary |
| 03-recovery-access-vpc.md | Recovery Access VPC |
| 04-core-recovery-vpc.md | Core Recovery VPC |
| 05-central-inspection-hub.md | Transit Gateway, Network Firewall, GWLB |
| 06-protected-data-vpc.md | Protected Recovery Data |
| 07-recovery-lifecycle.md | End-to-End Recovery Workflow |
| 08-security-principles.md | Zero Trust, Segmentation, Governance |
| 09-architecture-decisions.md | Why this architecture was selected |
| 10-conclusion.md | Executive Summary & Future Roadmap |

---

# Reading Order

For first-time readers:

1. README.md
2. Administrative Access
3. Recovery Access VPC
4. Core Recovery VPC
5. Inspection Hub
6. Protected Data VPC
7. Recovery Lifecycle
8. Security Principles
9. Architecture Decisions
10. Conclusion

---

# Guiding Principle

> **The objective of this architecture is not simply to recover infrastructure. The objective is to recover trust. Every design decision in this document exists to ensure that recovered systems are secure, validated, governed, and trustworthy before they are returned to business operations.**