# Presentation Transcript -- The Cyber Resiliency Blueprint

## Slide 1 -- Title

Good morning everyone.

Today I'd like to walk you through the architectural evolution of our
proposed Isolated Recovery Environment on AWS.

Rather than starting with the final design, I'd like to explain the
journey we took to get there, the alternatives we evaluated, the
trade-offs we identified, and ultimately why we are recommending the
three-VPC architecture.

The objective throughout this exercise was straightforward:

**To build an isolated recovery environment that remains trustworthy
even if production has been compromised.**

------------------------------------------------------------------------

## Slide 2 -- Executive Summary

Before we look at the architectures, I'd like to summarize the problem
we're solving.

Today, our production workloads and recovery assets exist within the
same overall trust boundary. If privileged credentials or identity
services are compromised, there is a risk that recovery assets could
also be affected.

Our recommendation is to establish a dedicated three-VPC Isolated
Recovery Environment, separating administrative access, recovery
operations, and protected recovery assets into independent trust
boundaries.

The goal is not simply to improve security---it is to create an
environment that supports trusted cyber recovery while aligning with our
compliance obligations.

By the end of this presentation, you'll see why this architecture
provides the best balance between security, operational simplicity, and
recoverability.

------------------------------------------------------------------------

## Slide 3 -- Why Now

This isn't simply an infrastructure modernization effort.

It is driven by compliance and cyber resilience.

HIPAA requires technical safeguards to protect sensitive healthcare
information, including backup and recovery processes.

Sheltered Harbor requires critical customer data to be stored in an
isolated and immutable environment.

Our current architecture does not fully satisfy those expectations
because production and recovery assets remain within the same trust
domain.

So the question isn't whether we need an isolated recovery environment.

The question is which architecture provides that capability without
introducing unnecessary operational complexity.

------------------------------------------------------------------------

## Slide 4 -- Journey

We evaluated four different architectural approaches.

We started with a traditional subnet-based design because it was simple.

As security requirements increased, we explored complete
micro-segmentation using five VPCs.

We then simplified that design into a two-VPC model.

Finally, after evaluating the strengths and weaknesses of each option,
we arrived at the recommended three-VPC architecture.

The next few slides explain why.

------------------------------------------------------------------------

## Slides 5--10

Keep these concise.

Each architecture solved one problem, but introduced another.

-   Flat subnet: simple, but insufficient isolation.
-   Five VPCs: excellent isolation, excessive complexity.
-   Two VPCs: simpler operations, reduced administrative separation.

These trade-offs naturally led us to the recommended architecture.

------------------------------------------------------------------------

## Slide 11 -- Recommended Architecture

After evaluating all previous approaches, we concluded that neither
extreme gave us what we needed.

The flat architecture lacked sufficient isolation.

The five-VPC model maximized isolation but became operationally complex.

The two-VPC model simplified operations but reduced administrative
separation.

The three-VPC architecture provides the right balance.

Each VPC has a clearly defined responsibility, reducing blast radius
while keeping the environment manageable and highly automatable.

------------------------------------------------------------------------

## Slide 12 -- Final Architecture (Main Walkthrough)

Let's walk through the recovery process from left to right.

Everything starts with the recovery administrator.

Administrators authenticate using enterprise identity with MFA and
connect securely using AWS Client VPN into the Recovery Access VPC.

This VPC exists solely for secure administrative access.

It hosts AWS Client VPN, Session Manager endpoints, and a standalone
Active Directory forest with **no trust relationship** to production.

Once authenticated, administrators access the recovery platform without
exposing workloads directly.

Moving into the **Core Recovery VPC**, this is where recovery execution
takes place.

Terraform provisions infrastructure consistently.

Ansible Automation Platform configures operating systems, middleware,
applications, and executes validation tasks.

Recovered workloads are brought online here and validated before
promotion.

Dedicated recovery domain controllers provide identity services
exclusively for recovered systems.

Between trust boundaries, communication is handled through AWS Transit
Gateway.

Traffic is inspected by AWS Network Firewall behind Gateway Load
Balancer, ensuring Zero Trust networking and preventing unrestricted
east-west communication.

Finally, we reach the **Protected Data VPC**.

This is the recovery vault.

It contains immutable backups protected with Amazon S3 Object Lock,
recovery metadata, landing zones, malware scanning, validation services,
EFS repositories, and supporting databases.

Recovery assets remain isolated until requested through approved
automation workflows.

Putting it all together:

-   Administrators enter through an isolated access layer.
-   Recovery automation executes in an independent recovery environment.
-   Protected recovery assets remain isolated inside the vault.
-   Every communication path is inspected.
-   Every identity is independent.
-   Every recovery asset is validated before restoration.

This layered architecture enables trusted recovery even when production
can no longer be trusted.

------------------------------------------------------------------------

## Slide 13 -- Technical HLD

This expands on the executive architecture by showing the detailed AWS
services supporting each trust boundary.

The underlying principles remain the same:

-   Administrative isolation
-   Automated recovery
-   Protected recovery assets
-   Centralized inspection

------------------------------------------------------------------------

## Slide 14 -- Structure

Recovery Access provides controlled administrative entry.

Core Recovery executes recovery automation.

Protected Data safeguards immutable recovery assets.

Separating responsibilities minimizes blast radius while simplifying
governance.

------------------------------------------------------------------------

## Slide 15 -- Compliance

The architecture aligns with HIPAA through strong identity controls,
least privilege, and protection of ePHI during recovery.

Sheltered Harbor requirements are met through isolated, immutable
storage.

We also map these controls to the NIST Cybersecurity Framework and align
with the AWS Isolated Recovery Environment reference architecture.

------------------------------------------------------------------------

## Slide 16 -- Benefits

The design is built around four principles:

-   Zero Trust networking
-   Independent identity
-   Automated recovery
-   Immutable recovery assets

Together they create a secure, repeatable, and operationally manageable
recovery environment.

------------------------------------------------------------------------

## Slide 17 -- Decision Matrix

To summarize:

The flat subnet architecture was simple but lacked isolation.

The five-VPC design maximized security but introduced excessive
complexity.

The two-VPC design simplified operations but weakened administrative
separation.

The recommended three-VPC architecture provides the best balance of
security, operational simplicity, compliance, and trusted recovery.

------------------------------------------------------------------------

## Slide 18 -- Closing

This proposal is not simply about building another disaster recovery
environment.

It is about creating a recovery platform that remains trustworthy when
production cannot be.

By separating administrative access, recovery execution, and protected
recovery assets into independent trust boundaries, the architecture
strengthens security while remaining practical to operate and automate.

We are seeking approval to proceed with the recommended three-VPC
Isolated Recovery Environment and begin implementation planning.

Thank you. I'd be happy to answer any questions.
