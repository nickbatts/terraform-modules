# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
}

# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name        = "${var.cloud_name}"
    Description = "Main VPC for organization"
    Creator     = "Terraform"
    Owner       = "DevOps"
  }
}
