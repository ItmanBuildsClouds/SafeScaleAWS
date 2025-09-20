variable "project_name" {
    type = string
}
variable "image_url" {
    type = string
}
variable "aws_region" {
    type = string
}
variable "environment" {
    type = string
}
variable "alb_target_group_arn" {
    type = string
}
variable "private_app_subnet_ids" {
    type = list(string)
}
variable "app_sg" {
    type = string
}
