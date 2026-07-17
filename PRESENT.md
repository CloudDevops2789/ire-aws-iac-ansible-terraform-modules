Slide 1 – Problem Statement

"Our objective was to design an AWS Isolated Recovery Environment (IRE) for Fairview that provides secure cyber recovery while remaining operationally simple, scalable, and 
aligned with AWS and healthcare security best practices."
----------
Slide 2 – Architecture Evolution
"Our initial design focused on isolating workloads within a single VPC using dedicated subnets for management, applications, protected data, and recovery services."

Advantages
Simple routing
Lower cost
Easy deployment

Challenges
Entire environment shared a single VPC security boundary
Larger blast radius
Limited network isolation
Difficult to apply different security policies between application and protected data

Then say
"Although operationally simple, we believed we could improve the isolation model."
----------
Phase 2 — Multiple Dedicated VPCs
The second iteration separated functions into dedicated VPCs for management, applications, protected data, recovery services, and administrative access."

Advantages:
Excellent isolation
Strong separation of duties
Independent security controls

Challenges:
Multiple Transit Gateway attachments
Complex routing
Numerous VPC endpoints
Increased operational overhead
Difficult troubleshooting
Higher cost
Longer recovery operations

"While this approach maximized isolation, it also introduced significant operational complexity that wasn't justified for Fairview's recovery requirements."
--------------
Phase 3 — Hybrid Three-VPC Architecture (Current)

Our Enterprise Architect also challenged the original approaches and recommended avoiding both the single-VPC and highly segmented multi-VPC models
"Instead, we adopted a balanced approach that separates applications from protected data while keeping routing and operations manageable."

Then summarize

Recovery Access VPC

↓

Recovery Services VPC

↓

Protected Data VPC

Exactly three trust zones.

--------------
"Bruce reviewed several AWS reference architectures containing separate Ingress, Inspection and Egress VPCs and recommended keeping our design at a higher level.
His suggestion was to consolidate those functions into a single Recovery Access VPC while maintaining equivalent security and functionality."

Then point to your Recovery Access VPC.
Say
"This design directly incorporates that recommendation."
---------
With that context, let me walk through the final architecture

Add one slide after the HLD
Architecture Decisions
Decision	Why we chose it
Recovery Access VPC	Consolidates remote administration, secure ingress and management functions into a dedicated administrative trust boundary.
Recovery Services VPC	Keeps application recovery, identity and automation together to simplify operations.
Protected Data VPC	Isolates PHI/PII and minimizes lateral movement.
Transit Gateway	Centralized routing, governance and future scalability.
AWS Network Firewall	Inspects only application-to-data traffic where the highest risk exists.
Immutable Recovery Repository	Ensures trusted recovery assets remain isolated from runtime workloads.
Infrastructure as Code	Enables repeatable, predictable rebuilds during recovery.

"This architecture wasn't designed to maximize the number of AWS services or network layers. It was designed to maximize confidence during recovery. 
Every iteration of the design challenged the balance between isolation, operational simplicity, and recoverability.
The final architecture reflects feedback from Enterprise Architecture, Cyber Recovery leadership, and AWS design principles,
resulting in a solution that is secure, maintainable, and operationally practical for Fairview."
