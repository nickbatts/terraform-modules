variable "cloud_name" {
  description = "Name of the Virtual Private Cloud"
  type        = "string"
  default     = "AppCloud"
}

variable "enable_private_subnet" {
  description = "Enable private subnet and get charged for provisioned NAT gateway"
  type        = "string"
  default     = "no"
}

variable "region" {
  description = "Region the vpc will live in"
  type        = "string"
  default     = "us-east-1"
}
