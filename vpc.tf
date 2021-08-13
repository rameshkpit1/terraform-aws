resource "aws_vpc" "vpc"{
    cidr_block="${var.vpc_cidr}"
    enable_dns_hostnames= true
    
    tags= {
        Name="Terraform_vpc"
    }
}
  
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.subnet_cidr)}"
  cidr_block              = "${element(var.subnet_cidr, count.index)}"
  availability_zone       = "${element(var.subnet_azs,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-subnet-${count.index}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnet_cidr)}"
  cidr_block              = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone       = "${element(var.public_subnet_azs,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet-${element(var.public_subnet_azs, count.index)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "private-route-table"
  }
}
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "public-route-table"
    # Environment = "${var.environment}"
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "terraformigw"
 #   Environment = "${var.environment}"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
   # Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_instance" "web" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "us-east-2c"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    subnet_id = "subnet-0be2c7fed6a2d2c4e"
    associate_public_ip_address = true
    source_dest_check = false


    tags = {
        Name = "Web Server 1"
    }
}
