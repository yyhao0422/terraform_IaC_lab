# Terraform lab (Fundamental)

This is a terraform fundamental lab aim to share terraform knowledge to Asia Pacific University Students and others to get started in Terraform.

## Objective

In this lab, you will create

- VPC with 1 Availability Zones (AZs) in us-east-1 region.

- Private EC2 instance t2.micro. The instance must use latest Amazon AMI 2023 OS.

- S3 bucket can be access by EC2.

- System administrator can access the EC2 via ec2 endpoint

## AWS Architecture

![AWS Architecture Diagram](https://github.com/yyhao0422/terraform_IaC_lab/blob/main/terraform_lab.png)

## AWS Infrastructure

**AWS:** VPC, EC2, S3, VPC endpoint, EC2 endpoint

**Cost:** Within free tier

## Lab Outline & Success Critera

- Create a VPC with three subnets (public, private, and database tiers) across 3 AZs.

- Provision a single EC2 instance in the public subnet (AZ-A) and allow SSH access.

- Verify connectivity to the EC2 instance.

- Able to connect s3 in ec2 using s3 endpoint.

## Installation

[Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## How to run the terraform ?

Open terminal and run:

```
terraform init

terraform plan

terraform apply -auto-approve
```

## Clean up AWS infrastructure

```
terraform destroy
```

## Documentation

Refer to terraform documentation for more customisation.

[Terraform AWS Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
