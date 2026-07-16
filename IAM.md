# AWS IAM Configuration for Red Hat AAP User and Role

## Overview

This document describes the IAM configuration required for the Red Hat Ansible Automation Platform (AAP) service account to provision and manage infrastructure within the AWS Isolated Recovery Environment (IRE).

The design follows AWS security best practices by using **STS AssumeRole** instead of assigning infrastructure permissions directly to an IAM user.

---

# Architecture

```
+---------------------------------------------------------+
| IAM User                                                |
| fhs-main-test-ire-redhataap-user                        |
+---------------------------------------------------------+
                    |
                    | sts:AssumeRole
                    v
+---------------------------------------------------------+
| IAM Role                                                |
| fhs-main-test-ire-redhataap-role                        |
+---------------------------------------------------------+
                    |
                    |
                    v
      AWS Resources managed by Terraform / AAP

      • VPC
      • EC2
      • Security Groups
      • Route Tables
      • NAT Gateway
      • Internet Gateway
      • S3
      • DynamoDB
      • Lambda
      • API Gateway
      • AWS Elastic Disaster Recovery
      • CloudWatch Logs
      • KMS
```

---

# Step 1 – Create IAM User

Create the following IAM user.

| Property | Value |
|----------|-------|
| User Name | **fhs-main-test-ire-redhataap-user** |

---

# Step 2 – Create Inline Policy for IAM User

Policy Name

```
fhs-main-test-ire-redhataap-user-inline1
```

Policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAssumeRole",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::781436988948:role/fhs-main-test-ire-redhataap-role"
        }
    ]
}
```

This policy grants the IAM user permission to assume the Red Hat AAP role.

---

# Step 3 – Create IAM Role

Role Name

```
fhs-main-test-ire-redhataap-role
```

Trust Relationship

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::781436988948:user/fhs-main-test-ire-redhataap-user"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

# Step 4 – Attach Inline Policy to Role

Policy Name

```
fhs-main-test-ire-redhataap-role-inline1
```

Attach the following inline policy to the role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RedHatRecommendedActions",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateKeyPair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSubnet",
        "ec2:CreateVpc",
        "ec2:DeleteKeyPair",
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:CreateTags",

        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:PutBucketVersioning",
        "s3:PutBucketEncryption",
        "s3:PutBucketTagging",

        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:UpdateTable",
        "dynamodb:DeleteTable",

        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:GetFunction",
        "lambda:DeleteFunction",
        "lambda:AddPermission",
        "lambda:RemovePermission",

        "apigateway:GET",
        "apigateway:POST",
        "apigateway:PATCH",
        "apigateway:DELETE",

        "drs:DescribeSourceServers",
        "drs:DescribeJobs",
        "drs:DescribeRecoveryInstances",
        "drs:StartRecovery",
        "drs:StartFailbackLaunch",
        "drs:RetryDataReplication",
        "drs:DisconnectRecoveryInstance",

        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:PutRetentionPolicy"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KmsForEncryption",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
```

---

# Additional Permissions Required

The Red Hat recommended permissions are sufficient for basic provisioning but are **not enough** for enterprise Terraform deployments. The following additional permissions are required.

---

## 1. VPC Management (Mandatory)

```
ec2:CreateVpc
ec2:DeleteVpc
ec2:ModifyVpcAttribute
ec2:DescribeVpcs
ec2:DescribeVpcAttribute
```

---

## 2. Internet Gateway (Mandatory)

```
ec2:CreateInternetGateway
ec2:DeleteInternetGateway
ec2:AttachInternetGateway
ec2:DetachInternetGateway
ec2:DescribeInternetGateways
```

---

## 3. NAT Gateway

Required when private subnets require outbound Internet access.

```
ec2:CreateNatGateway
ec2:DeleteNatGateway
ec2:DescribeNatGateways
```

---

## 4. Elastic IP

Required by NAT Gateway.

```
ec2:AllocateAddress
ec2:AssociateAddress
ec2:DisassociateAddress
ec2:ReleaseAddress
ec2:DescribeAddresses
```

---

## 5. Route Tables

```
ec2:CreateRouteTable
ec2:DeleteRouteTable
ec2:AssociateRouteTable
ec2:DisassociateRouteTable
ec2:CreateRoute
ec2:ReplaceRoute
ec2:DeleteRoute
ec2:DescribeRouteTables
```

---

## 6. Subnets

```
ec2:CreateSubnet
ec2:DeleteSubnet
ec2:ModifySubnetAttribute
ec2:DescribeSubnets
```

---

## 7. Security Groups

```
ec2:CreateSecurityGroup
ec2:DeleteSecurityGroup
ec2:AuthorizeSecurityGroupIngress
ec2:AuthorizeSecurityGroupEgress
ec2:RevokeSecurityGroupIngress
ec2:RevokeSecurityGroupEgress
ec2:DescribeSecurityGroups
```

---

## 8. Network ACLs

```
ec2:CreateNetworkAcl
ec2:DeleteNetworkAcl
ec2:CreateNetworkAclEntry
ec2:ReplaceNetworkAclEntry
ec2:DeleteNetworkAclEntry
ec2:DescribeNetworkAcls
```

---

## 9. VPC Peering

```
ec2:CreateVpcPeeringConnection
ec2:DeleteVpcPeeringConnection
ec2:AcceptVpcPeeringConnection
ec2:DescribeVpcPeeringConnections
```

---

## 10. EC2

```
ec2:RunInstances
ec2:TerminateInstances
ec2:StartInstances
ec2:StopInstances
ec2:RebootInstances
ec2:ModifyInstanceAttribute
ec2:DescribeInstances
ec2:DescribeInstanceStatus
ec2:DescribeImages
ec2:DescribeInstanceTypes
```

---

## 11. EBS

```
ec2:CreateVolume
ec2:DeleteVolume
ec2:AttachVolume
ec2:DetachVolume
ec2:ModifyVolume
ec2:DescribeVolumes
ec2:CreateSnapshot
ec2:DeleteSnapshot
ec2:DescribeSnapshots
```

---

## 12. Tagging (Mandatory)

```
ec2:CreateTags
ec2:DeleteTags
```

---

## 13. IAM Permissions (Least Privilege)

### Option 1 – Pass Existing Roles (Recommended)

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:GetRole",
    "iam:PassRole",
    "iam:ListRoles"
  ],
  "Resource": [
    "arn:aws:iam::<ACCOUNT_ID>:role/fhs-*"
  ]
}
```

---

### Option 2 – Create IAM Resources

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:CreateRole",
    "iam:DeleteRole",
    "iam:UpdateRole",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
    "iam:PutRolePolicy",
    "iam:DeleteRolePolicy",
    "iam:TagRole",
    "iam:UntagRole",
    "iam:GetRole",
    "iam:ListRoles"
  ],
  "Resource": [
    "arn:aws:iam::<ACCOUNT_ID>:role/fhs-*"
  ]
}
```

---

## 14. S3 Object Lock

Required for immutable backup repositories.

```
s3:PutBucketObjectLockConfiguration
s3:GetBucketObjectLockConfiguration
```

---

# Security Model

The recommended authentication flow is:

```
AAP User
      │
      ▼
IAM User
(fhs-main-test-ire-redhataap-user)
      │
      │ sts:AssumeRole
      ▼
IAM Role
(fhs-main-test-ire-redhataap-role)
      │
      ▼
Terraform
      │
      ▼
AWS Infrastructure
```

This model provides:

- Least privilege access
- Short-lived STS credentials
- No long-lived administrator permissions
- Centralized permission management
- Separation of authentication and authorization
- Alignment with AWS security best practices

---

# Summary

The implementation consists of:

- **IAM User:** `fhs-main-test-ire-redhataap-user`
- **User Inline Policy:** `fhs-main-test-ire-redhataap-user-inline1`
- **IAM Role:** `fhs-main-test-ire-redhataap-role`
- **Role Inline Policy:** `fhs-main-test-ire-redhataap-role-inline1`
- **STS AssumeRole** authentication model
- Additional enterprise permissions for networking, IAM, storage, compute, and immutable S3 Object Lock support.