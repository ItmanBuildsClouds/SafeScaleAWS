output "aws_lb_listener" {
    value = aws_lb_listener.http.arn
}

output "alb_target_group_arn" {
    value = aws_lb_target_group.app_lb_target.arn
}