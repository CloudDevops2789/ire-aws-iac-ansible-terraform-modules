# 02 – Administrative Access Trust Boundary

---

# Purpose

The Administrative Access Trust Boundary is the first layer of the AWS Isolated Recovery Environment (IRE). It provides the only approved entry point into the recovery platform and is responsible for verifying the identity of administrators before they are permitted to interact with any recovery resources.

Unlike traditional disaster recovery environments, administrators never connect directly to recovery workloads or protected data. Every administrative session must first pass through a dedicated authentication and authorization boundary designed to enforce Zero Trust principles.

This layer answers a single question:

> **Who is requesting access to the recovery environment?**

---

# Business Problem

Modern ransomware attacks rarely stop at encrypting production servers.

Attackers routinely attempt to compromise:

- Privileged administrator accounts
- Active Directory
- Identity Providers
- VPN infrastructure
- Backup systems
- Recovery environments

If an attacker successfully compromises administrative credentials, they may gain unrestricted access to the very environment intended to restore business operations.

The Isolated Recovery Environment cannot assume that production administrative identities remain trustworthy during a cyber incident.

Therefore, before any administrator reaches the recovery platform, the architecture establishes an independent trust boundary responsible for authenticating identities, enforcing strong authentication, authorizing access, and recording every privileged activity.

---

# Design Objectives

The Administrative Access Trust Boundary has been designed to achieve the following objectives:

- Verify administrator identity before granting access.
- Prevent direct administrative access to recovery workloads.
- Enforce Multi-Factor Authentication (MFA).
- Eliminate public management interfaces such as SSH and RDP.
- Provide encrypted administrative connectivity.
- Ensure every administrative action is fully auditable.
- Maintain administrative access even if production identity services are unavailable.

---

# Presentation Script

Let's begin from the left-hand side of the architecture, which represents the **Administrative Access Trust Boundary**. This is the only approved entry point into the Isolated Recovery Environment (IRE).

One of our key design principles is that no administrator, application, or external system can directly access the recovery workloads or protected data.

During a cyber attack, one of the first assets attackers target is privileged administrative access. If an attacker compromises an administrator's credentials, we don't want them to gain unrestricted access to the recovery environment.

Therefore, before anyone reaches the recovery platform, they must pass through a dedicated authentication and authorization boundary.

---

# Why a Separate Trust Boundary?

Imagine a bank.

```
Outside World
      │
      ▼
Security Gate
      │
      ▼
Employee Area
      │
      ▼
Vault
```

Customers never walk directly into the vault.

Everyone first passes through security.

The Administrative Access Trust Boundary follows exactly the same principle.

```
Internet
      │
      ▼
Administrative Access
      │
      ▼
Recovery Access VPC
      │
      ▼
Core Recovery VPC
      │
      ▼
Protected Data VPC
```

Each boundary reduces the blast radius if any upstream component is compromised.

Rather than trusting users simply because they originate from the corporate network, every administrator must prove their identity before progressing further into the recovery environment.

---

# Recovery Administrators

Recovery administrators are a very small group of authorized personnel responsible for cyber recovery activities.

These accounts are intentionally separated from standard production administrative accounts.

Elevated privileges are granted only during an officially declared recovery event and follow the principle of Least Privilege.

## Why Separate Recovery Identities?

If production administrative credentials are compromised, an attacker should not automatically gain administrative access to the recovery environment.

Maintaining dedicated recovery identities ensures that recovery remains possible even if production identity services are unavailable or compromised.

---

# Identity Verification

## Multi-Factor Authentication (MFA)

Authentication requires more than a username and password.

Administrators must successfully present multiple authentication factors, typically a password combined with a hardware token or authenticator application.

Passwords alone are frequently stolen through phishing, credential reuse, or malware.

MFA significantly reduces the likelihood that stolen credentials alone can be used to access the recovery platform.

---

## Security Assertion Markup Language (SAML)

SAML enables enterprise identity providers such as Microsoft Entra ID or Okta to authenticate users without AWS storing enterprise passwords.

Think of SAML as a trusted receptionist.

AWS asks:

> "Is this administrator really Yoganand?"

Microsoft Entra ID replies:

> "Yes. I have already verified the identity."

AWS trusts that response without ever seeing the administrator's password.

---

## OpenID Connect (OIDC)

OIDC performs a similar function using modern OAuth standards and JSON Web Tokens.

Many cloud-native identity providers use OIDC instead of SAML.

Regardless of protocol, the architectural objective remains the same:

AWS never authenticates enterprise passwords directly.

Authentication is delegated to a trusted identity provider.

---

# Secure Administrative Connectivity

## AWS Client VPN

Once authentication succeeds, administrators establish a TLS 1.2 encrypted session into AWS using AWS Client VPN.

```
Administrator Laptop
        │
        ▼
TLS 1.2 Encrypted Tunnel
        │
        ▼
AWS Client VPN
        │
        ▼
Recovery Access VPC
```

The VPN provides:

- Encryption
- Authentication
- Authorization
- Centralized Logging
- Centralized Access Control

---

## Why Not SSH Directly?

Direct SSH introduces several operational and security challenges.

It requires:

- Public IP addresses
- Open inbound ports
- SSH key management
- Additional monitoring
- Greater exposure to internet-based attacks

Using AWS Client VPN eliminates the need for exposing recovery infrastructure directly to the Internet while centralizing administrative access.

---

# Systems Manager Session Manager

VPN establishes secure connectivity into the recovery environment.

Session Manager establishes secure connectivity to individual instances.

Instead of opening inbound SSH or RDP ports, administrators connect through the AWS Systems Manager control plane.

No inbound management ports are required.

---

## Analogy

The VPN is like entering a secure office building.

Session Manager is like asking the receptionist to escort you directly to your meeting room rather than wandering through every corridor.

---

## Why Use Both VPN and Session Manager?

Both services solve different problems.

| Service | Primary Purpose |
|----------|-----------------|
| AWS Client VPN | Secure access to the private administrative network |
| Session Manager | Secure management of EC2 instances without SSH or RDP |

Together they provide flexible administration while maintaining Zero Trust principles.

---

# Why No Internet Gateway?

Administrative connectivity terminates inside the Recovery Access VPC.

After authentication, all communication remains on private AWS networking.

Recovery servers never expose public management interfaces.

---

# Why Not Use a Bastion Host?

Traditional bastion hosts require:

- Operating system patching
- SSH key lifecycle management
- Continuous monitoring
- Hardening
- Backup
- Availability management

AWS Client VPN combined with Systems Manager Session Manager significantly reduces operational overhead while leveraging fully managed AWS services.

---

# Failure Scenarios

## What if Microsoft Entra ID Is Compromised?

The recovery environment maintains independent recovery administrative identities and break-glass procedures.

Recovery operations do not blindly trust production identity infrastructure.

---

## What if VPN Connectivity Is Lost?

Systems Manager Session Manager provides an alternate management path through the AWS management plane, reducing dependency on VPN availability for emergency administration.

---

# Architecture Decision

The Administrative Access Trust Boundary exists solely to establish trust before administrators interact with recovery resources.

It intentionally performs **identity verification only**.

Recovery operations occur later within the Core Recovery VPC.

This separation follows the principle of Separation of Duties and reduces the likelihood that compromised administrative endpoints can directly impact recovery assets.

---

# Alternatives Considered

| Alternative | Why Rejected |
|------------|--------------|
| Direct SSH | Public exposure, poor auditability |
| Bastion Hosts | Higher operational overhead |
| Shared Production Identities | Production compromise could extend into recovery |
| Public RDP Access | Increased attack surface |

---

# AWS Well-Architected Alignment

| Pillar | Implementation |
|---------|----------------|
| Security | MFA, SAML/OIDC, Session Manager, Least Privilege |
| Reliability | Independent recovery identities and alternate management paths |
| Operational Excellence | Managed authentication services and centralized administration |
| Performance Efficiency | Managed AWS services reduce operational complexity |
| Cost Optimization | Eliminates dedicated bastion infrastructure where appropriate |

---

# Risks Mitigated

| Risk | Mitigation |
|------|------------|
| Credential Theft | MFA and federated authentication |
| Public Management Exposure | Private management channels |
| Privilege Escalation | Dedicated recovery identities |
| Unauthorized Administrative Access | Centralized authentication and authorization |
| Loss of Audit Evidence | CloudTrail and Session Manager logging |

---

# Key Takeaways

- Administrative access is intentionally isolated from recovery operations.
- Every administrator must establish trust before entering the recovery environment.
- AWS Client VPN provides secure network connectivity.
- Systems Manager Session Manager provides secure instance management without public SSH or RDP.
- Dedicated recovery identities reduce dependence on potentially compromised production identity services.
- This trust boundary answers one question:

> **Who is requesting access to the recovery environment?**

Only after that question has been answered does the architecture permit administrators to proceed into the Recovery Access VPC.