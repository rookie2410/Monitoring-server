variable "ami_id" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}
