output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "instance_id" {
  value = aws_instance.instance.id
}

output "security_group_id" {
  value = aws_security_group.sg.id
}