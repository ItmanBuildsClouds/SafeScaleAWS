output "vpc_id" {
    value =  aws_vpc.main_vpc.id
}
output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public: subnet.id]
}
output "app_subnet_ids" {
    value = [for subnet in aws_subnet.private_app: subnet.id]
}
output "db_subnet_ids" {
    value = [for subnet in aws_subnet.private_db: subnet.id]
}

output "alb_sg" {
    value = aws_security_group.alb.id
}
output "app_sg" {
    value = aws_security_group.app.id
}
output "db_sg" {
    value = aws_security_group.db.id
}

