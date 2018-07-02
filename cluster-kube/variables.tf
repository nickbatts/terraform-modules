variable "asg_desired_count" {
  description = "How many instances would you like in this ASG?"
  type        = "string"
  default     = "1"
}

variable "cluster_name" {
  description = "Name of the Elastic Kubernetes Cluster"
  type        = "string"
  default     = "TEST"
}

variable "instance_type" {
  description = "EC2 instance type to use for cluster instances - default: t2.micro"
  type        = "string"
  default     = "t2.micro"
}

variable "region" {
  description = "AWS region to create kubernetes cluster in, e.g. us-east-1, us-west-1, us-west-2"
  type        = "string"
  default     = "us-east-1"
}

variable "spot_price" {
  description = "If set, ASG will use spot instances with this variable as max bid price."
  type        = "string"
  default     = ""
}
