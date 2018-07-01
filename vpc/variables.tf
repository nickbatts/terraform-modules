variable "cloud_name" {
  type        = "string"
  default     = "AppCloud"
  description = "Name of the Virtual Private Cloud"
}

variable "enable_private_subnet" {
  type        = "string"
  default     = "no"
  description = "Enable private subnet and get charged for provisioned NAT gateway"
}

variable "environment" {
  type        = "string"
  default     = "DEV"
  description = "TEST|DEV|QA|STAGING|PROD"
}

variable "region" {
  type        = "string"
  default     = "us-east-1"
  description = "Region the vpc will live in"
}
