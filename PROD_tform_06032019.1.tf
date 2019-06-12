#This configuration file performs the following steps:
#Set the Public Cloud Provider
#Setup a VPC "IaC-test-env"
#Setup a subnet "subnet-IaC"
#Setup a security group "ingress-all-test" and attach it to VPC "Iac-test-env"
#Launch three EC2 CENTOS instances - Web, App, DB
#Attach an elastic IP to each instance
#Setup an Internet Gateway 
#Setup a route to the instances
#If this files name begins with PROD, it is ready for production
#If this files name begins with DEV, the file is still being developed
#This file assumes that a .tfvars file is present in the same directory as this file
#To build infrastructure, run this file with terraform apply
#To destroy infrastructure, run this file with terraform destroy

############

#Set Provider
provider "aws" {
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
        region = "${var.aws_region}"
}

#Setup VPC
resource "aws_vpc" "IaC-test-env" {
  cidr_block = "10.10.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
}

#Setup Subnets
resource "aws_subnet" "subnet-IaC" {
  cidr_block = "${cidrsubnet(aws_vpc.IaC-test-env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.IaC-test-env.id}"
  availability_zone = "us-west-1a"
}

#Setup Security Groups
resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.IaC-test-env.id}"
  ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

#Launch EC2 Instance
resource "aws_instance" "web" {
  ami = "ami-007d9b63"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-IaC.id}"
  key_name = "IaC_Prod"
}

#Attach an Elastic IP
resource "aws_vpc" "IaC-web-eip" {
  cidr_block = "10.10.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
}
resource "aws_instance" "app" {
  ami = "ami-007d9b63"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-IaC.id}"
  key_name = "IaC_Prod"
}

#Attach an Elastic IP
resource "aws_vpc" "IaC-app-eip" {
  cidr_block = "10.10.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
}
resource "aws_instance" "db" {
  ami = "ami-007d9b63"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-IaC.id}"
  key_name = "IaC_Prod"
}

#Attach an Elastic IP
resource "aws_vpc" "IaC-db-eip" {
  cidr_block = "10.10.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
}
resource "aws_eip" "ip-IaC-test-env" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

#setup Internet Gateway
resource "aws_internet_gateway" "IaC-test-env-gw" {
  vpc_id = "${aws_vpc.IaC-test-env.id}"
}

#Setup Route Table
resource "aws_route_table" "route-table-IaC-test-env" {
  vpc_id = "${aws_vpc.IaC-test-env.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IaC-test-env-gw.id}"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-IaC.id}"
  route_table_id = "${aws_route_table.route-table-IaC-test-env.id}"
}
#END
