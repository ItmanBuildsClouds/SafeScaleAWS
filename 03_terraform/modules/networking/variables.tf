variable "cidr_block" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}
variable "aws_region" {
    type = string
    default = "eu-central-1"
}
variable "project_name" {
    type = string
    default = "default-name"
}
variable "environment" {
    type = string
    default = "default"
}
variable "public_cidrs" {
    type = map(string)
    default = {
        "a" = "10.0.1.0/24"
        "b" = "10.0.2.0/24"
    }
}
variable "private_app_cidrs" {
    type = map(string)
    default = {
        "a" = "10.0.3.0/24"
        "b" = "10.0.4.0/24"
    }
}
variable "private_db_cidrs" {
    type = map(string)
    default = {
        "a" = "10.0.5.0/24"
        "b" = "10.0.6.0/24"
    }
}
