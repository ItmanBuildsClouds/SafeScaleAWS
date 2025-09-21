resource "aws_ecs_cluster" "ecs" {
    name = "${var.project_name}-ecs"

    setting {
      name = "containerInsights"
      value = "enabled"
    }
}


data "aws_iam_policy_document" "ecs-assume-role-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs-task-execution" {
    name = "${var.project_name}-ecs-execution"
    assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attach" {
    role = aws_iam_role.ecs-task-execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
    family = "${var.project_name}-app-task"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"

    cpu = "1024"
    memory = "2048"

    execution_role_arn = aws_iam_role.ecs-task-execution.arn


    container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app-container"
      image     = var.image_url
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
            "awslogs-group" = "/ecs/${var.project_name}-app"
            "awslogs-region" = var.aws_region
            "awslogs-stream-prefix" = "app"
        }
      }
    },
    ])
    tags = {
        Name = "${var.project_name}-ecs"
        Project = var.project_name
        Environment = var.environment
    }
}

resource "aws_cloudwatch_log_group" "app_logs" {
    name = "/ecs/${var.project_name}-app"
    retention_in_days = 7

    tags = {
        Name = "${var.project_name}-app-logs"
        Project = var.project_name
        Environment = var.environment
    }
}


resource "aws_ecs_service" "ecs-service" {
    name = "${var.project_name}-service"
    cluster = aws_ecs_cluster.ecs.id
    task_definition = aws_ecs_task_definition.ecs-task-definition.arn
    desired_count = 2
    depends_on = [ aws_iam_role.ecs-task-execution ]
    launch_type = "FARGATE"

    load_balancer {
      target_group_arn = var.alb_target_group_arn

      container_name = "${var.project_name}-app-container"

      container_port = 5000
    }

network_configuration {
  subnets = var.private_app_subnet_ids
  security_groups = [var.app_sg]
  assign_public_ip = false

}
tags = {
    Name = "${var.project_name}-ecs-service"
    Project = var.project_name
    Environment = var.environment
}
}