resource "aws_lb" "app_lb" {
    name = "${var.project_name}-lb"
    security_groups = [var.alb_sg]
    subnets = var.public_subnet_ids
    enable_deletion_protection = false

    tags = {
    Name = "${var.project_name}-app-lb"
    Project = var.project_name
    Environment = var.environment
    }
}

resource "aws_lb_target_group" "app_lb_target" {
    name = "${var.project_name}-lb-target"
    port = 5000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"

    health_check {
      path = "/health"
      protocol = "HTTP"
      matcher = "200"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward" 
      target_group_arn = aws_lb_target_group.app_lb_target.arn
}
}