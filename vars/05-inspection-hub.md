# 05 – Central Inspection Hub

---

# Purpose

The Central Inspection Hub is the security enforcement layer of the AWS Isolated Recovery Environment (IRE).

It acts as the controlled gateway through which traffic flows between trust boundaries. Rather than allowing direct communication between VPCs, all inter-VPC traffic is routed through this centralized inspection layer where it is validated, filtered, monitored, and logged before being permitted to continue.

This trust boundary answers one question:

> **Should this traffic be trusted to proceed?**

---

# Business Problem

One of the primary objectives of modern ransomware is lateral movement.

Once an attacker compromises one workload, they attempt to move across servers, networks, and applications to reach privileged systems, backup repositories, or sensitive data.

If workloads within the recovery environment communicate directly with one another, a compromise in one area can rapidly spread throughout the recovery platform.

The architecture therefore introduces a dedicated inspection layer to ensure that **every network flow between trust boundaries is explicitly inspected and authorized**.

---

# Design Objectives

The Central Inspection Hub has been designed to:

- Eliminate direct VPC-to-VPC communication.
- Inspect all east-west traffic.
- Prevent lateral movement.
- Centralize network security policy.
- Provide deep visibility into network traffic.
- Simplify security governance.
- Support future security service integration.

---

# Presentation Script

The Central Inspection Hub is the security checkpoint of the entire recovery environment.

Neither administrators nor workloads communicate directly with other trust boundaries.

Instead, every packet destined for another VPC is first redirected to the inspection hub.

Only traffic that satisfies security policy is permitted to continue.

Think of this as airport baggage screening.

Every bag passes through the scanner.

Nothing bypasses inspection simply because the passenger has already checked in.

Similarly, no packet bypasses inspection simply because it originates from inside the recovery environment.

---

# Why a Central Inspection Layer?

Without centralized inspection:

```
Core Recovery VPC
        │
        ▼
Protected Data VPC
```

Every VPC would require its own complex security controls.

Policy management becomes inconsistent.

Troubleshooting becomes difficult.

Auditability decreases.

Instead, the architecture centralizes inspection.

```
Core Recovery VPC
        │
        ▼
Transit Gateway
        │
        ▼
Network Firewall
        │
        ▼
Gateway Load Balancer
        │
        ▼
Protected Data VPC
```

Every communication path follows the same security controls.

---

# High-Level Architecture

```
              Recovery Access VPC
                      │
                      ▼
               Core Recovery VPC
                      │
                      ▼
             AWS Transit Gateway
                      │
        ┌─────────────┴─────────────┐
        ▼                           ▼
 AWS Network Firewall      Gateway Load Balancer
        │                           │
        └─────────────┬─────────────┘
                      ▼
            Protected Data VPC
```

---

# AWS Transit Gateway

The Transit Gateway provides centralized connectivity between the Recovery Access VPC, Core Recovery VPC, Protected Data VPC, and future recovery networks.

Instead of configuring dozens of individual VPC peering connections, every VPC establishes a single attachment to the Transit Gateway.

Benefits include:

- Simplified routing
- Scalable architecture
- Centralized network management
- Consistent security enforcement

### Why not VPC Peering?

As the number of VPCs increases, peering relationships grow rapidly and become operationally difficult to manage.

Transit Gateway provides a hub-and-spoke model that is easier to scale and aligns with enterprise networking practices.

---

# AWS Network Firewall

The Network Firewall performs stateful inspection of traffic flowing between trust boundaries.

It evaluates every connection against centrally managed security policies before permitting traffic.

Typical inspection includes:

- Source and destination validation
- Port and protocol filtering
- Domain-based filtering
- Threat intelligence rules
- Stateful packet inspection

Only approved traffic is forwarded.

Everything else is blocked and logged.

---

# Gateway Load Balancer (GWLB)

The Gateway Load Balancer enables transparent insertion of security appliances into the network path.

It distributes traffic across one or more inspection appliances without requiring application or workload changes.

Benefits include:

- High availability
- Horizontal scaling
- Transparent traffic steering
- Simplified security operations

If additional inspection capabilities are required in the future, new appliances can be introduced without redesigning application connectivity.

---

# East-West Traffic Inspection

Traditional firewalls primarily inspect north-south traffic between internal networks and the internet.

The recovery environment places greater emphasis on east-west traffic.

Examples include:

- Application to database communication
- Terraform to AWS APIs
- Ansible to EC2 instances
- Recovery servers accessing repositories

Every one of these flows is subject to centralized inspection.

---

# Security Policy

Inspection policies follow the principle of least privilege.

Examples include:

- Allow Ansible to communicate only with managed instances.
- Allow application servers to access approved databases.
- Allow Route 53 Resolver traffic.
- Deny all unauthorized lateral movement.
- Block unapproved outbound communication.

Security policy is centrally managed rather than distributed across individual VPCs.

---

# Logging and Visibility

Every inspected flow generates security evidence.

Typical logging includes:

- Allowed connections
- Blocked connections
- Threat detections
- Firewall rule matches
- Network anomalies

These logs support:

- Incident response
- Forensic investigations
- Compliance reporting
- Security auditing

---

# High Availability

The Central Inspection Hub is deployed across multiple Availability Zones.

Security inspection must remain available even during infrastructure failures.

Multiple firewall endpoints and Gateway Load Balancer endpoints ensure that inspection continues if an Availability Zone becomes unavailable.

---

# Why Isn't Inspection Performed Inside Each VPC?

Placing inspection inside every VPC would create:

- Duplicate firewall policies
- Inconsistent security rules
- Increased operational effort
- Higher management overhead
- More difficult auditing

A centralized inspection layer provides:

- Consistent policy enforcement
- Simplified governance
- Easier operations
- Better scalability

---

# Design Decisions

## Why Transit Gateway?

A centralized routing hub simplifies network design and ensures all inter-VPC communication passes through a common control point.

---

## Why Network Firewall?

Stateful inspection provides stronger security than relying solely on Security Groups and Network ACLs.

---

## Why Gateway Load Balancer?

It allows inspection services to scale independently of application workloads while supporting future third-party security appliances if required.

---

# Alternatives Considered

| Alternative | Reason Rejected |
|-------------|-----------------|
| Direct VPC Peering | Poor scalability and inconsistent policy enforcement |
| Distributed firewalls in each VPC | Operational complexity and duplicated configuration |
| Security Groups only | Instance-level protection without centralized inspection |
| Network ACLs only | Stateless filtering and limited visibility |

---

# AWS Well-Architected Alignment

| Pillar | Implementation |
|---------|----------------|
| Security | Centralized inspection, stateful firewalling, least privilege |
| Reliability | Multi-AZ Transit Gateway attachments and firewall endpoints |
| Operational Excellence | Centralized security management |
| Performance Efficiency | Scalable hub-and-spoke networking |
| Cost Optimization | Shared inspection infrastructure reduces duplicated security services |

---

# Risks Mitigated

| Risk | Mitigation |
|------|------------|
| Lateral movement | Mandatory inter-VPC inspection |
| Unauthorized communication | Stateful firewall policies |
| Inconsistent security controls | Centralized policy management |
| Undetected malicious traffic | Comprehensive inspection and logging |
| Scaling limitations | Transit Gateway and Gateway Load Balancer architecture |

---

# Architecture Decision

The Central Inspection Hub intentionally separates network security from application workloads.

Application owners remain responsible for their applications.

Security teams remain responsible for inspection policies.

This separation of duties strengthens governance while simplifying operational ownership.

---

# Architecture Review Questions

During design reviews, common questions include:

- Why is Transit Gateway preferred over VPC Peering?
- Why is AWS Network Firewall required if Security Groups already exist?
- What types of traffic are inspected?
- How is encrypted traffic handled?
- Can inspection become a bottleneck?
- How are firewall policies updated and governed?
- What happens if a firewall endpoint becomes unavailable?
- How are new VPCs integrated into the inspection architecture?

These questions should be addressed during detailed design and operational readiness reviews.

---

# Key Takeaways

- The Central Inspection Hub is the security enforcement layer of the IRE.
- All inter-VPC communication traverses a centralized inspection path.
- AWS Transit Gateway provides scalable hub-and-spoke connectivity.
- AWS Network Firewall performs stateful traffic inspection and policy enforcement.
- Gateway Load Balancer enables scalable, highly available security services.
- Centralized inspection prevents uncontrolled lateral movement and improves governance.
- This trust boundary answers one question:

> **Should this traffic be trusted to proceed?**

Only after traffic has been inspected and authorized is it permitted to access the Protected Data VPC, where the organization's most valuable recovery assets are stored.