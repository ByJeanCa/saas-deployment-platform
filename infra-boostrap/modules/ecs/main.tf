resource "aws_cloudwatch_log_group" "ecs_fargate_logs" {
  name              = format("/ecs/%s-%s", var.project_name, var.environment)
  retention_in_days = 14
  tags              = var.common_tags

}

resource "aws_iam_role" "api_task_execution" {
  name = format("api-task-execution-role-%s", var.project_name)
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "api_execution_secrets" {
  name = "api-task-execution-secrets-role"
  role = aws_iam_role.api_task_execution.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : "${var.db_master_secret_arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_task_execution" {
  role       = aws_iam_role.api_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "api" {
  family = format("api-%s-%s-td", var.project_name, var.region)

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.api_task_execution.arn


  container_definitions = jsonencode([
    {
      name      = format("api-%s-%s-cd", var.project_name, var.region),
      image     = "${var.api_image}:${var.image_tag}",
      essential = true,

      secrets = [
        {
          name      = "DB_USER",
          valueFrom = "${var.db_master_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD",
          valueFrom = "${var.db_master_secret_arn}:password::"
        }
      ],

      portMappings = [
        {
          containerPort = 8000,
          protocol      = "tcp"
        }
      ],

      environment = [
        { name = "ENV", value = var.environment },
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_NAME", value = var.db_name },
        { name = "REDIS_URL", value = var.redis_url },
        { name = "DB_PORT", value = "5432" }
      ],

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_fargate_logs.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = var.common_tags
}

resource "aws_iam_role" "task_execution" {
  name = format("task-execution-role-%s", var.project_name)
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "frontend" {
  family = format("frontend-%s-%s-td", var.project_name, var.region)

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.task_execution.arn


  container_definitions = jsonencode([
    {
      name      = format("frontend-%s-%s-cd", var.project_name, var.region),
      image     = "${var.frontend_image}:${var.image_tag}",
      essential = true,

      portMappings = [
        {
          containerPort = 8080,
          protocol      = "tcp"
        }
      ],

      environment = [
        { name = "API_BASE_URL", value = "/api" },
      ],

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_fargate_logs.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = var.common_tags
}

resource "aws_ecs_task_definition" "worker" {
  family = format("worker-%s-%s-td", var.project_name, var.region)

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.task_execution.arn


  container_definitions = jsonencode([
    {
      name      = format("worker-%s-%s-cd", var.project_name, var.region),
      image     = "${var.worker_image}:${var.image_tag}",
      essential = true,

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_fargate_logs.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = var.common_tags
}

resource "aws_ecs_cluster" "main" {
  name = format("%s-svc-%s", var.project_name, var.environment)

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

resource "aws_ecs_service" "api" {
  name            = format("api-%s-svc-%s", var.project_name, var.environment)
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 0

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.ecs_service_sg_id]
  }

  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = format("api-%s-%s-cd", var.project_name, var.region)
    container_port   = 8000
  }
}

resource "aws_ecs_service" "frontend" {
  name            = format("frontend-%s-svc-%s", var.project_name, var.environment)
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 0

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.ecs_service_sg_id]
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = format("frontend-%s-%s-cd", var.project_name, var.region)
    container_port   = 8080
  }
}

resource "aws_ecs_service" "worker" {
  name            = format("worker-%s-svc-%s", var.project_name, var.environment)
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 0

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.ecs_service_sg_id]
  }
}


resource "aws_appautoscaling_target" "api" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"

  min_capacity = 0
  max_capacity = 3
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "${var.project_name}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  resource_id        = aws_appautoscaling_target.api.resource_id

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 120
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}