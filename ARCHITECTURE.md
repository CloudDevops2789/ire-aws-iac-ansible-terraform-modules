# AWS Isolated Recovery Environment (IRE)

> **Enterprise Cyber Recovery Architecture**  
> **Version:** 1.0 (Draft)  
> **Status:** Architecture Review

---

<img width="1536" height="1024" alt="IRE_Architecture" src="https://github.com/user-attachments/assets/021ef877-aa04-40b5-836d-7687d832d682" />


## Table of Contents

- Executive Summary
- Objectives
- Design Principles
- Architecture Overview
- Network Architecture
- Security Architecture
- Identity Strategy
- Backup & Recovery
- Traffic Flows
- AWS Managed Services
- Security Controls
- Design Decisions
- Repository Structure
- Recovery Workflow
- Implementation Roadmap
- Future Enhancements

---

# Executive Summary

This repository contains the reference architecture and implementation guidance for an **AWS Isolated Recovery Environment (IRE)** designed for enterprise cyber recovery.

The solution provides a **secure, isolated, immutable recovery platform** capable of restoring critical workloads after ransomware or cyber incidents while minimizing dependencies on production infrastructure.

The architecture follows:

- Zero Trust
- Least Privilege
- Infrastructure as Code
- Immutable Infrastructure
- AWS Managed Services First
- Defense in Depth

---

# Objectives

- Recover critical workloads securely
- Eliminate runtime dependencies on production
- Minimize blast radius
- Protect PHI / PII
- Automate recovery
- Reduce RTO and RPO
- Enable immutable backups
- Support HIPAA and enterprise security controls

---

# Design Principles

| Principle | Description |
|----------|-------------|
| Zero Trust | Never trust any network segment by default |
| Isolation | Separate application and protected data |
| Immutable Infrastructure | Rebuild instead of repair |
| Automation | Terraform + Ansible Automation Platform |
| Least Privilege | IAM, SGs and KMS follow minimum permissions |
| AWS Managed Services | Minimize self-managed infrastructure |

---

# Architecture Overview

## Core VPC

Contains:

- AWS Managed Microsoft AD
- Route53 Private Hosted Zone
- Route53 Resolver
- AWS Systems Manager
- CloudWatch
- AWS Config
- GuardDuty
- Security Hub
- CloudTrail
- AWS KMS
- Secrets Manager
- Terraform
- Red Hat AAP
- Validation Servers
- Internal ALB + AWS WAF
- Web Tier
- Application Tier

Purpose:

- Identity
- Management
- Recovery Services
- Application Hosting

---

## Protected Data VPC

Contains:

- Amazon Aurora
- Amazon RDS
- Amazon FSx
- Amazon EFS
- PHI / PII Storage
- Backup Landing Zone
- Malware Scan
- Validation
- Restore Orchestration

Purpose:

- Protect sensitive healthcare workloads
- Isolate databases and storage
- Controlled backup ingestion

---

## Transit Gateway

Provides:

- Centralized routing
- Controlled east-west traffic
- Route table segmentation
- Future scalability

---

## AWS Network Firewall

Inspects traffic between:

Core VPC

↓

Protected Data VPC

---

## Offline Repository

Contains:

- S3 Object Lock
- Golden AMIs
- ECR Mirror
- Terraform Modules
- Patch Repository
- Application Packages
- Backup Vault

---

# Network Architecture

## Administrative Access

Recovery Administrator

↓

AWS Client VPN

↓

Management Subnet

↓

AWS Systems Manager

↓

Application Resources

---

## Business User Access

Business User

↓

Island Browser / Citrix

↓

AWS PrivateLink

↓

Internal ALB

↓

Recovered Applications

---

## Backup Ingestion

On-Premises

↓

Site-to-Site VPN

↓

Dedicated Ingestion Subnet

↓

Malware Scan

↓

Validation

↓

Protected Storage

---

# Identity Strategy

The IRE should operate independently from production identity providers during recovery.

Recommendations:

- Use isolated recovery identity services
- Synchronize only recovery-critical identities
- One-way synchronization
- Periodic synchronization aligned with business RPO
- Support multiple enterprise IdPs where required
- Eliminate runtime dependency on production identity services

---

# Backup & Recovery Strategy

- Immutable backups
- S3 Object Lock
- Cross-account backup copy
- Malware scanning
- Validation before restore
- Automated promotion into protected storage

---

# AWS Managed Services

| Service | Purpose |
|----------|----------|
| AWS Managed Microsoft AD | Identity |
| Route53 | DNS |
| Systems Manager | Administration |
| CloudWatch | Monitoring |
| GuardDuty | Threat Detection |
| Security Hub | Security Aggregation |
| CloudTrail | Audit |
| AWS Config | Compliance |
| Secrets Manager | Secrets |
| AWS KMS | Encryption |
| Amazon Aurora | Database |
| Amazon RDS | Database |
| Amazon FSx | File Storage |
| Amazon EFS | Shared Storage |
| AWS Backup | Immutable Backup |
| Amazon ECR | Container Images |
| Amazon S3 | Offline Repository |

---

# Security Controls

- AWS Organizations SCPs
- IAM Least Privilege
- MFA
- AWS Client VPN
- AWS Network Firewall
- Security Groups
- Network ACLs
- AWS WAF
- AWS Config
- GuardDuty
- Security Hub
- CloudTrail
- KMS Encryption
- Secrets Manager
- VPC Endpoints Only
- No Internet Gateway
- No NAT Gateway

---

# Design Decisions

| Decision | Rationale |
|----------|-----------|
| Two VPC Architecture | Balance between security and operational simplicity |
| Transit Gateway | Centralized governance and routing |
| AWS Network Firewall | East-west inspection |
| Dedicated Data VPC | Reduce blast radius |
| VPC Endpoints | Private AWS service access |
| Terraform | Immutable Infrastructure |
| Red Hat AAP | Recovery automation |

---

# Repository Structure

```text
terraform/
├── modules/
│   ├── networking/
│   ├── security/
│   ├── identity/
│   ├── storage/
│   ├── backup/
│   └── recovery/
├── environments/
│   ├── dev/
│   ├── test/
│   └── prod/
└── backend/

ansible/
├── playbooks/
├── roles/
├── inventory/
├── validation/
└── restore/
```

---

# Recovery Workflow

```text
Immutable Backup
        │
        ▼
Backup Validation
        │
        ▼
Terraform Provisioning
        │
        ▼
Golden AMI Deployment
        │
        ▼
Ansible Configuration
        │
        ▼
Application Restore
        │
        ▼
Security Validation
        │
        ▼
Business Access
```

---

# Enterprise Architect Recommendations

- Two VPC hybrid architecture
- AWS Network Firewall between VPCs
- Transit Gateway for governance
- Dedicated Protected Data VPC
- GuardDuty across all workloads
- AWS WAF on Internal ALB
- Terraform drift detection
- Dedicated backup ingestion subnet
- Validate and scan backups before promotion

---

# Implementation Roadmap

| Phase | Deliverable |
|--------|-------------|
| 1 | Core Networking |
| 2 | IAM & Identity |
| 3 | Protected Data Services |
| 4 | Backup & Offline Repository |
| 5 | Terraform Modules |
| 6 | Ansible Automation |
| 7 | Validation Framework |
| 8 | End-to-End Recovery Testing |

---

# Future Enhancements

- AWS Verified Access
- IAM Identity Center
- Cross-Region Recovery
- Backup Audit Manager
- Automated Compliance
- Policy as Code
- Continuous Security Validation

**For Client VPN / Landing Zones , We have two proposed solutions**
**Option 1 **- Client VPN in Core VPC (Simpler)

<img width="752" height="257" alt="image" src="https://github.com/user-attachments/assets/99174a4d-2e08-4164-a7ec-f58afc9126df" />


Internet
    │
AWS Client VPN
    │
Management Subnet
(Core VPC)
    │
SSM
    │
Application Servers

**Advantages**
Simpler architecture
Lower cost
Fewer route tables
Easier to manage

**Disadvantages**
VPN terminates inside the same VPC as workloads.
Administrative entry point shares the same security boundary as applications.
If the management subnet is compromised, the attacker is already inside the Core VPC.

Option 2 - Dedicated Recovery Access VPC

<img width="754" height="263" alt="image" src="https://github.com/user-attachments/assets/dd997da6-66a0-4046-b017-4005f85bea1a" />


                    Internet
                        │
               AWS Client VPN
                MFA + SAML/OIDC
                        │
             Recovery Access VPC
             (Management Only)
                        │
             AWS Systems Manager
             Bastion (Optional)
             Jump Services
             Logging
                        │
              Transit Gateway
                        │
      ┌─────────────────┴──────────────────┐
      │                                    │
  Core VPC / managemnt                         Protected Data VPC
  
 Only administrative traffic originates from the Recovery Access VPC.Business users never enter this VPC.
 Benefits:
 1. Separate Trust Boundary
  * Recovery administrators land here first.
  * They do not land directly inside the application network.

 2. Better Segmentation
  * You can inspect traffic before it reaches workloads.
    
 3. Easier Auditing
  * Everything starts here: VPN logs, CloudTrail , GuardDuty , Session Manager , Admin workstation and its one place to monitor

 4. Easier Expansion without modifying application VPCs.since we can add Security tooling , Forensics , SIEM collectors , Vulnerability scanners , Incident response tooling at later stages

 5. Zero Trust , Nobody can directly connect to: EC2 , DB , FSx , EFS Everything passes through the management layer

 Note: AWS Security Reference Architecture promotes centralized management separated from workloads. IAM , Systems Manager , CloudTrail , Security Hub, GuardDuty , AWS Config, Client VPN, Session Manager all in a dedicated management/security boundary.

 Our EA has  recommended reducing complexity from 5 to two VPCs because the original five-VPC design introduced too much operational overhead. We can plan to introduce a third VPC, since this is having a clear security purpose (administrator ingress)

 Recovery Access VPC focused on administrator access.
 Core Recovery VPC hosting identity, management, and application services.
 Protected Data VPC containing sensitive databases and storage.

You can inspect traffic before it reaches workloads.


Keeping Option 2 in mind using Recovery Access VPC as an additional 3rd VPC

<img width="1536" height="1024" alt="3VPCArchitecture" src="https://github.com/user-attachments/assets/5a2d8578-c22e-400d-a2fb-d3c65d3a3994" />

---

# References

- AWS Well-Architected Framework
- AWS Security Reference Architecture (SRA)
- AWS Prescriptive Guidance – Cyber Recovery
- NIST Cybersecurity Framework
- CIS AWS Foundations Benchmark

---


