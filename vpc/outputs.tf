# output VPC, availability zones and CIDR blocks

output "VPC_ID" {
  value = "${aws_vpc.main.id}"
}

output "VPC_name" {
  value = "${aws_vpc.main.tags.Name}"
}

output "VPC cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "Zones" {
  value = "${data.aws_availability_zones.available.names}"
}
