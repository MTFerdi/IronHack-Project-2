variable "project" {
  type    = string
  default = "ironhack-project-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "ca-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_suffix" {
  type    = string
  default = "a"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_app_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_db_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

# For security, set your public_ip/32 later
variable "my_ip_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/ironhack_aws.pub"
}

variable "key_pair_name" {
  type    = string
  default = "ironhack-aws-key"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "backend_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_type" {
  type    = string
  default = "t3.micro"
}
