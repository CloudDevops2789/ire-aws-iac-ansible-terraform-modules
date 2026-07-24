# 01 – Introduction

---

# Document Information

| Property | Value |
|----------|-------|
| Document Name | AWS Isolated Recovery Environment (IRE) – Enterprise Architecture Design |
| Document Type | High-Level Design (HLD) |
| Version | 1.0 |
| Status | Draft |
| Classification | Internal Use Only |
| Prepared By | Infrastructure Engineering |
| Architecture Pattern | AWS Isolated Recovery Environment (IRE) |
| Cloud Platform | Amazon Web Services (AWS) |

---

# Purpose

This document describes the architecture, design principles, security model, operational workflow, and implementation strategy for the Fairview Health Services AWS Isolated Recovery Environment (IRE).

The purpose of this architecture is not simply to recover workloads after a disaster.

Its purpose is to provide a **trusted**, **isolated**, and **secure** platform capable of recovering business services even when the production environment has been completely compromised by a cyberattack.

This document serves as both a technical implementation guide and an architectural decision record, explaining not only **what** was designed but also **why** each design decision was made.

---

# Background

Traditional Disaster Recovery (DR) environments were designed to address hardware failures, natural disasters, and data center outages.

Modern ransomware attacks have fundamentally changed the recovery landscape.

Threat actors no longer target only production workloads. They also attempt to compromise:

- Active Directory
- Identity providers
- Backup infrastructure
- Disaster Recovery environments
- Administrative credentials
- Management servers
- Hypervisors
- Recovery consoles

If the recovery environment shares the same trust boundaries as production, the organization risks restoring systems into another compromised environment.

Recovery today is no longer simply about restoring systems.

It is about restoring systems into an environment that can itself be trusted.

---

# Business Problem

The organization requires an enterprise recovery platform capable of operating independently from production during a cyber incident.

The recovery platform must:

- Remain operational even if production identity services are unavailable.
- Prevent compromised administrator credentials from automatically granting access.
- Protect recovery artifacts from deletion or modification.
- Prevent lateral movement between recovery components.
- Provide complete auditability for recovery operations.
- Rebuild infrastructure consistently using Infrastructure as Code.
- Validate every recovery artifact before restoration.
- Support business governance before production cutover.

These requirements extend beyond traditional disaster recovery and align with modern cyber recovery objectives.

---

# Vision

The vision of the AWS Isolated Recovery Environment is to establish a trusted recovery platform that enables the organization to recover business services securely, consistently, and confidently.

Every architectural decision within the environment is evaluated against three guiding questions:

1. Does this improve security?
2. Does this simplify recovery?
3. Does this reduce operational risk?

Only design decisions that satisfy these objectives are incorporated into the architecture.

---

# Design Goals

The architecture has been developed with the following primary goals.

## Security

- Zero Trust Architecture
- Least Privilege Access
- Defense in Depth
- Independent Trust Boundaries
- Immutable Recovery Storage

## Resilience

- Multi-Availability Zone deployment
- Independent identity services
- Independent DNS services
- Trusted recovery repositories
- High availability for critical components

## Operational Excellence

- Infrastructure as Code using Terraform
- Configuration as Code using Red Hat Ansible Automation Platform
- Automated validation
- Standardized recovery workflows
- Reduced manual intervention

## Governance

- Approval workflows
- Audit evidence
- Centralized logging
- Compliance reporting
- Recovery validation

---

# Scope

This document describes the architecture of the AWS Isolated Recovery Environment, including:

- Administrative Access Trust Boundary
- Recovery Access VPC
- Core Recovery VPC
- Central Inspection Hub
- Protected Data VPC
- Identity Strategy
- Automation Strategy
- Recovery Workflow
- Security Principles
- Architecture Decisions
- Governance Model
- Future Roadmap

---

# Out of Scope

The following topics are outside the scope of this document:

- Application-specific recovery procedures
- Business Continuity Planning (BCP)
- Disaster Recovery runbooks for individual applications
- AWS account provisioning
- Cost estimation
- Detailed Terraform module implementation
- Detailed Ansible playbook implementation

These topics are expected to be documented separately.

---

# Architecture Philosophy

The architecture is designed around **trust boundaries**, not merely network segmentation.

Each boundary performs a single, clearly defined function.

| Trust Boundary | Primary Responsibility |
|----------------|------------------------|
| Administrative Access | Verify administrator identity |
| Recovery Access VPC | Establish trusted administrative sessions |
| Core Recovery VPC | Execute recovery operations |
| Central Inspection Hub | Inspect and control east-west traffic |
| Protected Data VPC | Protect enterprise recovery assets |

No component is implicitly trusted.

Every request must be authenticated, authorized, inspected, validated, or approved before progressing to the next layer.

This layered approach reduces the blast radius of a compromise while preserving the integrity of the recovery environment.

---

# Guiding Principles

The architecture is built upon the following principles:

- Zero Trust
- Least Privilege
- Defense in Depth
- Separation of Duties
- Automation First
- Immutability
- High Availability
- Governance and Auditability

These principles are reflected throughout every architectural decision documented in subsequent chapters.

---

# Architecture Evolution

Several architecture models were evaluated before selecting the final design.

## Option 1 – Single VPC with Subnets

### Advantages

- Simple networking
- Lower cost
- Easy deployment

### Limitations

- Shared trust boundary
- Increased blast radius
- Limited security isolation
- Greater risk of lateral movement

**Decision:** Rejected

---

## Option 2 – Five-VPC Architecture

### Advantages

- Strong isolation
- Fine-grained segmentation
- Maximum separation of responsibilities

### Limitations

- Complex routing
- Higher operational overhead
- Increased Transit Gateway complexity
- Longer recovery deployment times
- Higher operational cost

**Decision:** Rejected

---

## Option 3 – Two-VPC Architecture

### Advantages

- Reduced networking complexity
- Simpler operations

### Limitations

- Administrative access and recovery operations share the same trust boundary
- Reduced separation of duties
- Higher operational risk

**Decision:** Rejected

---

## Final Design – Three-VPC Architecture

The selected architecture separates responsibilities into three independent trust boundaries.

| VPC | Responsibility |
|-----|----------------|
| Recovery Access | Administrative ingress |
| Core Recovery | Recovery orchestration |
| Protected Data | Recovery assets |

The three-VPC architecture provides the best balance between:

- Security
- Simplicity
- Scalability
- Governance
- Operational efficiency
- Recovery speed

---

# Intended Audience

This document is intended for:

- Enterprise Architects
- AWS Solutions Architects
- Cloud Security Engineers
- Infrastructure Engineers
- Platform Engineers
- Disaster Recovery Teams
- Cyber Recovery Teams
- Operations Teams
- Audit and Compliance Teams
- Executive Leadership
- Architecture Review Board

---

# Document Structure

The remainder of this document is organized as follows:

| Chapter | Description |
|----------|-------------|
| 02 | Administrative Access Trust Boundary |
| 03 | Recovery Access VPC |
| 04 | Core Recovery VPC |
| 05 | Central Inspection Hub |
| 06 | Protected Data VPC |
| 07 | Recovery Lifecycle |
| 08 | Security Principles |
| 09 | Architecture Decisions |
| 10 | Conclusion and Future Roadmap |

---

# Key Message

The objective of this architecture is **not simply to recover infrastructure**.

The objective is to **recover trust**.

Every architectural decision—from identity verification and network segmentation to immutable storage and automated recovery—exists to ensure that restored systems are secure, validated, governed, and ready to support business operations with confidence.
