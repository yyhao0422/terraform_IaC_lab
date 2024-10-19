# VPC
resource "aws_vpc" "application_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform_lab_vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {

  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

}
# Private Subnet
resource "aws_subnet" "private_subnet" {

  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "terraform_lab_igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "terraform_lab_nat_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "terraform_lab_nat_gateway"
  }
}


# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform_lab_public_rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "terraform_lab_private_rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.application_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]


  tags = {
    Name = "terraform_lab_s3_gateway_endpoint"
  }
}


# EC2 Instance Endpoint
resource "aws_security_group" "ec2_instance_connect_sg" {
  vpc_id = aws_vpc.application_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "terraform_lab_ec2_instance_connect"
  }
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
  subnet_id = aws_subnet.private_subnet.id

  security_group_ids = [aws_security_group.ec2_instance_connect_sg.id]

  tags = {
    Name = "terraform_lab_ec2_instance_connect"
  }
}

# S3 Bucket
resource "random_id" "simple_bucket_hex" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_lab_bucket" {
  bucket = "terraform-lab-bucket-${random_id.simple_bucket_hex.hex}"

  force_destroy = true

  tags = {
    Name = "terraform_lab_bucket-asjdofnokno2"
  }
}

# EC2 Instance
# 1. Create EC2 IAM Instance Profile with IAM ROLE policy attached (S3 Full Access, SSM Instance Core)
# 2. Create EC2 Instance with Security Group

resource "aws_iam_role" "ec2_role" {
  name = "terraform-lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "terraform_lab_ec2_role"
  }
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "terraform-lab-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "terraform_lab_ec2_instance_profile"
  }
}


resource "aws_security_group" "ec2_instance_sg" {
  vpc_id = aws_vpc.application_vpc.id
  name   = "terraform-lab-ec2-sg"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_instance_connect_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_lab_ec2_sg"
  }
}

resource "aws_instance" "private_instance" {
  ami                  = "ami-0ddc798b3f1a5117e"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups      = [aws_security_group.ec2_instance_sg.id]

  tags = {
    Name = "private_instance"
  }
}

# BONUS : Create Public Instance with Apache httpd server
# Success Criteria:
# 1. Able to access the instance via public IP address
# 2. Able to connect to the instance via SSM Session Manager


# Reminder: Clean up your resources after you are done with the lab using terraform destroy
