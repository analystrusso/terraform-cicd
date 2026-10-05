variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.10.0/24"
}

variable "env_prefix" {
  type    = string
  default = "dev"
}

variable "avail_zone" {
  type    = string
  default = "us-east-1a"
}

variable "my_ip" {
  type        = string
  default = "173.49.58.219/32"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_public_key" {
  type = string
}