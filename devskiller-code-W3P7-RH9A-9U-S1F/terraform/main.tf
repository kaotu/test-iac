# Summary steps to create the infrastructure
# 1. Create a VPC, Subnet, Internet Gateway, Route Table.
# 2. Create a EC2 instance type t2.micro in that subnet, AZ eu-central-1.
    # 2.1. Adjust EBS, device name /dev/sdc and AZ eu-central-1
# 3. Create Security Group, allow SSH.
# 4. Create a EIP 10.0.10.250 and Attach the EIP to the EC2 instance.

# 1. Create a VPC, Subnet, Internet Gateway, Route Table.
resource "aws_vpc" "vpc" {
  cidr_block       = local.vpc_cidr_block
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_euce1"
  }
}

# Create a default security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default_sg"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.subnet_cidr_blocks
  availability_zone       = "eu-central-1"
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet_euce1"
  }
}

# Create a Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route_table_euce1"
  }
}

# Association to route table
resource "aws_route_table_association" "route_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Create a Internat Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw_euce1"
  }
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 2. Create a EC2 instance type t2.micro in that subnet, AZ eu-central-1.
resource "aws_instance" "instance" {
  ami             = "ami-0be656e75e69af1a9"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.name]

  private_ip = local.private_ip
  subnet_id  = aws_subnet.subnet.id

  # 2.1. Adjust EBS, device name /dev/sdc and AZ eu-central-1
  ebs_block_device {
    device_name = "/dev/sdc"
  }
}

# 3. Create Security Group, allow SSH.
resource "aws_security_group" "sg" {
  name        = "instance-sg"
  description = "For access instance"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# 4. Create a EIP 10.0.10.250 and Attach the EIP to the EC2 instance.
resource "aws_eip" "eip" {
  domain = "vpc"

  instance                  = aws_instance.instance.id
  associate_with_private_ip = local.private_ip
  depends_on                = [aws_internet_gateway.igw]
}