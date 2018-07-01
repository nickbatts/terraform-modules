provider "aws" {
  region = "${var.region}"
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.5.0.0/16"
  enable_dns_hostnames = true

  tags = "${
    map(
     "Name", "AppCloud",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.available.names)}"

  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  cidr_block              = "10.5.${count.index}.0/24"
  vpc_id                  = "${aws_vpc.main.id}"

  tags = "${
    map(
     "Name", "tf-public-sn-${element(data.aws_availability_zones.available.names, count.index)}",
     "Description", "Public subnets for VPC",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "tf-eks-ig"
    Description = "Terraform managed Internet gateway."
  }
}

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
}

resource "aws_route_table_association" "public" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-routes.id}"
}
