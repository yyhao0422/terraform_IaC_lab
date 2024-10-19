
# Terraform lab (Fundamental)

This is a terraform fundamental lab aim to share terraform knowledge to Asia Pacific University Students and others to get started in Terraform.



## Objective

In this lab, you will create

-  VPC with 3 Availability Zones (AZs) in Singapore region.

-  Public EC2 instance t3.micro. The instance must use latest Amazon AMI 2023 OS.

-  S3 bucket can be access by EC2.

-  Public EC2 instance can access Internet and system administrator can access the EC2 with specific public IPv4 address

- Apache Website configured inside the public EC2 instance during Terraform provisioning.


## AWS Architecture

![AWS Architecture Diagram](https://via.placeholder.com/468x300?text=App+Screenshot+Here)


## AWS Infrastructure

**AWS:** VPC, EC2, S3, VPC endpoint

**Cost:** Within free tier




## Lab Outline & Success Critera

- Create a VPC with three subnets (public, private, and database tiers) across 3 AZs.

- Provision a single EC2 instance in the public subnet (AZ-A) and allow SSH access.

-  Verify connectivity to the EC2 instance.

-  User able to go to Apache Website.




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

