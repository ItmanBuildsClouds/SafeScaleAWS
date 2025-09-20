variable "vpc_id" {
    type = string
}

variable "alb_sg" {
    type = string
}

variable "app_sg" {
    type = string
}

variable "image_url" {
    type = string
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "aws_region" {
    type = string
}

variable "public_subnet_ids" {
    type = list(string)
}