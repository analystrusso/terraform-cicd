variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
    default = "10.0.10.0/24"
}
variable "env_prefix" {
    default = "dev"
}
variable "avail_zone" {
    default = "us-east-1a"
}
variable "my_ip" {
    default = "173.49.58.219/32"
}
variable "instance_type" {
    default = "t2.micro"
}