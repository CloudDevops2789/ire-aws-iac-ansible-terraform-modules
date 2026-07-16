# Assume Role

This role assumes an AWS IAM role using amazon.aws.sts_assume_role.

## Requirements

- amazon.aws collection
- boto3
- botocore
- Bootstrap IAM credentials
- sts:AssumeRole permission

## Variables

role_arn
aws_region
role_external_id
role_session_duration_seconds
application_name

## Facts

aws_access_key_id
aws_secret_access_key
aws_session_token
aws_role_expiration
aws_assumed_role_arn
aws_auth

## Usage

```yaml
- hosts: localhost
  gather_facts: false

  vars:

    role_arn: arn:aws:iam::123456789012:role/fhs-main-test-ire-role

    aws_region: us-east-1

    application_name: recovery

  roles:

    - fairview.aws.assume_role