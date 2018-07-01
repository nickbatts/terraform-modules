# load availability zones
data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.cloud_name}-IGW"
    Description = "Allow internet access from public subnets"
    Creator     = "Terraform"
  }
}

resource "aws_eip" "nat" {
  count      = "${var.enable_private_subnet == "yes" ? 1 : 0}"
  vpc        = true
  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  count         = "${var.enable_private_subnet == "yes" ? 1 : 0}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"

  tags {
    Name        = "${var.cloud_name}-NGW"
    Description = "Allow internet access from private subnets"
    Creator     = "Terraform"
  }

  depends_on = ["aws_internet_gateway.default", "aws_eip.nat"]
}

## Public subnets

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.${count.index * 1}.0/24"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "publicSN-${element(data.aws_availability_zones.available.names, count.index)}"
    Description = "Public subnet for VPC"
    Creator     = "Terraform"
    Public      = "true"
    Tier        = "WEB"
  }

  depends_on = ["aws_internet_gateway.default"]
}

## Public Subnets Routing Table

resource "aws_route_table" "public-routes" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name        = "publicSN-routes"
    Description = "public routes for VPC"
    Creator     = "Terraform"
  }

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_route_table_association" "public" {
  count          = "${aws_subnet.public.count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-routes.id}"

  depends_on = ["aws_route_table.public-routes"]
}

## Private subnets

resource "aws_subnet" "private" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.${count.index + aws_subnet.public.count + 1}.0/24"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "privateSN-${element(data.aws_availability_zones.available.names, count.index)}"
    Description = "private subnet for VPC"
    Creator     = "Terraform"
    Public      = "false"
    Tier        = "DB"
  }

  depends_on = ["aws_internet_gateway.default"]
}

## Private Subnets Routing Table

resource "aws_route_table" "private-routes" {
  vpc_id = "${aws_vpc.main.id}"
  count  = "${var.enable_private_subnet == "yes" ? 1 : 0}"

  route {
    cidr_block = "0.0.0.0/0"

    #instance_id = "${aws_instance.nat.id}"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name        = "privateSN-routes"
    Description = "private routes for VPC"
    Creator     = "Terraform"
  }

  depends_on = ["aws_nat_gateway.nat"]
}

resource "aws_route_table_association" "private" {
  count          = "${var.enable_private_subnet == "yes" ? aws_subnet.private.count : 0}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-routes.id}"

  depends_on = ["aws_route_table.private-routes"]
}
