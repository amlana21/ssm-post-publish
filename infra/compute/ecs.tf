data "aws_caller_identity" "current" {}




resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# --------------------app task definition--------------------

resource "aws_cloudwatch_log_group" "nginx-logs" {
  name = "/nginx-logs"  

  retention_in_days = 30  
}

resource "aws_ecs_task_definition" "nginx_task_definition" {
  family                   = "app-task-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx",
      image     = "public.ecr.aws/nginx/nginx:1.27",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ],  
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/nginx-logs"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "nginx"
        }
      },
      
    }
  ])
}


resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task_definition.id
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.task_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_grp_arn
    container_name   = "nginx"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nginx_discovery.arn
  }

}