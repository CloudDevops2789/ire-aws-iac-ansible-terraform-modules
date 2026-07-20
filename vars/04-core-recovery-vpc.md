# 04 – Core Recovery VPC

---

# Purpose

The Core Recovery VPC is the operational heart of the AWS Isolated Recovery Environment (IRE). Once administrators have successfully passed through the Administrative Access Trust Boundary and the Recovery Access VPC, they enter the Core Recovery VPC where recovery activities are orchestrated, automated, validated, and executed.

Unlike the Recovery Access VPC, which focuses on secure administrative ingress, the Core Recovery VPC performs the actual work of rebuilding infrastructure, restoring applications, validating services, and preparing workloads for business use.

This trust boundary answers one fundamental question:

> **How do we securely recover the environment?**

---

# Business Problem

During a ransomware attack, the production environment cannot be trusted. Servers may be encrypted, Active Directory may be compromised, infrastructure may have been modified, and applications may no longer function correctly.

Recovery cannot begin directly within production because there is no guarantee that the environment remains secure or operational.

The organization therefore requires an isolated operational environment capable of rebuilding infrastructure from trusted definitions, restoring approved recovery artifacts, validating workloads, and ensuring applications are safe before production cutover.

The Core Recovery VPC fulfills this requirement.

---

# Design Objectives

The Core Recovery VPC has been designed to:

- Orchestrate end-to-end recovery activities.
- Rebuild AWS infrastructure using Infrastructure as Code.
- Configure operating systems and applications through automation.
- Maintain independent identity services.
- Host trusted software repositories.
- Validate recovered workloads before production cutover.
- Provide continuous operational monitoring.
- Maintain high availability throughout the recovery process.

---

# Presentation Script

Once an administrator has been authenticated, authorized, and has established a trusted administrative session, they do not directly access protected recovery assets.

Instead, they enter the Core Recovery VPC, which acts as the operational brain of the entire Isolated Recovery Environment.

Unlike the Recovery Access VPC, which verifies identity and establishes secure access, the Core Recovery VPC performs the actual work of recovering business services.

---

# Hospital Analogy

Think of the architecture as a hospital.

```
Recovery Access VPC      → Reception
Core Recovery VPC        → Operating Theatre
Protected Data VPC       → Blood Bank & Medicine Vault
```

The reception desk verifies who may enter.

The operating theatre performs surgery.

The blood bank safeguards the critical resources needed during treatment.

Similarly, the Core Recovery VPC performs the recovery while protected recovery assets remain isolated within the Protected Data VPC.

---

# High-Level Architecture

```
                    Recovery Access VPC
                            │
                            ▼
                 Core Recovery VPC
                            │
        ┌───────────────────┼────────────────────┐
        ▼                   ▼                    ▼
 Terraform            Ansible AAP        AWS Managed AD
        │                   │                    │
        ├──────────────┬────┴─────────────┐
        ▼              ▼                  ▼
 Restore Servers  Validation Servers  Application Servers
                            │
                            ▼
                   Recovery Repository
                            │
                            ▼
                  Inspection Hub (TGW)
```

---

# Core Components

## Recovery Infrastructure

The Recovery Infrastructure represents the compute layer responsible for executing recovery activities.

Typical workloads include:

- Restore Servers
- Validation Servers
- Application Servers
- Recovery Workloads

These systems are provisioned only when required and are rebuilt from trusted definitions rather than reused from potentially compromised production infrastructure.

### Why recover here instead of production?

Production may still contain:

- Malware
- Unauthorized configuration changes
- Compromised identities
- Incomplete remediation

Recovering within an isolated environment allows workloads to be validated before being returned to business operations.

---

# AWS Managed Microsoft Active Directory

Identity is fundamental to every enterprise application.

The recovery environment maintains an independent AWS Managed Microsoft Active Directory so that authentication and authorization remain available even if production identity services are compromised.

### Business Rationale

Applications cannot function without identity services.

Authentication, authorization, Kerberos, LDAP, and Group Policy all depend upon a trusted directory.

Maintaining an independent directory ensures recovery operations remain possible even if production Active Directory has been encrypted or compromised.

### Analogy

Imagine the company's headquarters burns down.

Would employee records exist only inside that building?

Of course not.

A trusted copy is maintained elsewhere.

AWS Managed Microsoft AD serves as that trusted copy during recovery.

### Why not use Production Active Directory?

If production Active Directory is compromised, relying on it would allow attackers to authenticate directly into the recovery platform.

Recovery must therefore maintain an independent identity service.

---

# Amazon Route 53 Resolver

Every workload communicates using DNS names rather than IP addresses.

For example:

```
database.fairview-ire.org
```

must ultimately resolve to an IP address.

Amazon Route 53 Resolver provides private DNS resolution within the recovery environment.

### Why is it needed?

Applications should never rely on production DNS during recovery.

Maintaining independent name resolution allows recovered services to communicate regardless of the state of production infrastructure.

---

# Terraform

Terraform is responsible for rebuilding cloud infrastructure.

Rather than manually creating VPCs, subnets, EC2 instances, IAM roles, and security groups during an emergency, Terraform recreates the entire environment from version-controlled Infrastructure as Code.

### Responsibilities

- VPC creation
- Subnet deployment
- Security Groups
- IAM Roles
- EC2 Infrastructure
- Networking Components

### Business Benefits

- Consistency
- Repeatability
- Reduced human error
- Faster recovery
- Version-controlled infrastructure

---

# Red Hat Ansible Automation Platform

Terraform provisions infrastructure.

Ansible configures it.

Once infrastructure exists, Red Hat Ansible Automation Platform performs:

- Operating system configuration
- Middleware deployment
- Application deployment
- Security hardening
- Service validation

This separation follows Infrastructure as Code best practices.

### Why separate Terraform and Ansible?

Terraform specializes in provisioning infrastructure.

Ansible specializes in configuring operating systems and applications.

Combining these tools provides a modular and repeatable recovery process.

---

# Amazon Elastic Container Registry (ECR)

Some enterprise applications are containerized.

Amazon ECR acts as the trusted software registry for these workloads.

Instead of downloading images from public repositories during recovery, workloads retrieve approved container images from the organization's private registry.

### Business Value

- Trusted software source
- Version control
- Improved governance
- Reduced supply chain risk

---

# Recovery Repository

The Recovery Repository stores trusted recovery assets used during orchestration.

It contains:

- Golden AMIs
- Terraform Modules
- Ansible Collections
- Container Images
- Recovery Runbooks
- RPM Repository

## Golden AMIs

Prebuilt, patched, hardened operating system images.

Instead of reinstalling and hardening servers during every recovery event, workloads are launched from trusted images.

---

## Terraform Modules

Reusable Infrastructure as Code components.

Rather than recreating infrastructure definitions for every application, standardized modules are reused across recovery scenarios.

---

## Ansible Collections

Reusable automation content including roles, playbooks, and modules.

This reduces duplication and promotes operational consistency.

---

## Recovery Runbooks

Automation should always have a documented fallback.

Runbooks provide step-by-step recovery guidance should manual intervention become necessary.

---

# Monitoring

Continuous monitoring ensures that recovered services remain operational.

Amazon CloudWatch monitors:

- CPU
- Memory
- Disk
- Logs
- Metrics
- Health Status

Monitoring answers questions such as:

- Did the application start successfully?
- Is the database responding?
- Are services healthy?

---

# Security Monitoring

Security visibility is provided through multiple AWS services.

| Service | Purpose |
|----------|---------|
| CloudTrail | Audit AWS API activity |
| GuardDuty | Threat detection |
| AWS Config | Configuration compliance |
| Security Hub | Centralized security posture |

Together they provide continuous operational and security visibility throughout the recovery process.

---

# High Availability

The Core Recovery VPC is deployed across multiple Availability Zones.

Recovery infrastructure must remain operational even during infrastructure failures.

Multi-AZ deployment eliminates single points of failure and ensures recovery activities continue if an Availability Zone becomes unavailable.

---

# Design Decisions

## Why isn't Object Lock located here?

Immutable recovery storage belongs in the Protected Data VPC.

The Core Recovery VPC consumes approved recovery artifacts but does not permanently store immutable business data.

---

## Why aren't production databases located here?

Business data remains protected within the Protected Data VPC.

Recovery compute should remain isolated from persistent enterprise data.

---

# Security Principle

The architecture can be summarized using three simple questions.

| Trust Boundary | Primary Question |
|----------------|------------------|
| Recovery Access | **Who** is requesting access? |
| Core Recovery | **How** do we recover the environment? |
| Protected Data | **What** are we protecting? |

This simple model explains the responsibilities of each VPC and reinforces the separation of duties across the architecture.

---

# Architecture Decision

The Core Recovery VPC exists solely to execute recovery operations.

It intentionally separates operational recovery activities from both administrative access and protected business data.

This separation improves security, governance, and operational consistency while reducing the likelihood that compromised recovery infrastructure can directly impact protected recovery assets.

---

# Alternatives Considered

| Alternative | Reason Rejected |
|-------------|-----------------|
| Recover directly in Production | Production may still be compromised |
| Shared Active Directory | Creates dependency on compromised identity services |
| Manual Infrastructure Builds | Slow, inconsistent, and error-prone |
| Public Software Repositories | Increased supply chain risk |

---

# AWS Well-Architected Alignment

| Pillar | Implementation |
|---------|----------------|
| Security | Independent identity, trusted repositories, IAM roles |
| Reliability | Multi-AZ deployment and automated recovery |
| Operational Excellence | Terraform, Ansible, standardized automation |
| Performance Efficiency | Automated provisioning and reusable components |
| Cost Optimization | Reusable Golden AMIs and Terraform modules |

---

# Risks Mitigated

| Risk | Mitigation |
|------|------------|
| Compromised production infrastructure | Isolated recovery environment |
| Identity compromise | Independent AWS Managed AD |
| Manual recovery errors | Terraform and Ansible |
| Supply chain attacks | Trusted ECR and recovery repositories |
| Configuration drift | Infrastructure as Code |

---

# Architecture Review Questions

During an architecture review, common questions include:

- Why does AWS Managed Microsoft AD belong in the Core Recovery VPC instead of the Recovery Access VPC?
- Why is Terraform located here rather than in the Protected Data VPC?
- Why are Golden AMIs treated as recovery artifacts?
- What happens if Ansible Automation Platform becomes unavailable?
- How are Golden AMIs validated before use?
- Why is Route 53 Resolver independent of production DNS?
- How is traffic between the Core Recovery VPC and the Protected Data VPC controlled?
- What evidence demonstrates that recovered workloads are trustworthy before production cutover?

These questions should be addressed during detailed design reviews and operational readiness assessments.

---

# Key Takeaways

- The Core Recovery VPC is the operational heart of the Isolated Recovery Environment.
- Terraform rebuilds infrastructure.
- Ansible configures operating systems and applications.
- AWS Managed Microsoft AD provides independent identity services.
- Route 53 Resolver provides private DNS independent of production.
- Trusted recovery repositories supply approved software and automation artifacts.
- Continuous monitoring validates recovery progress.
- This trust boundary answers one question:

> **How do we securely recover the environment?**

Only after recovery operations have completed does traffic proceed through the Central Inspection Hub before any interaction with protected recovery data.