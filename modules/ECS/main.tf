data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#IAM role for the ecs task defination
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole2"
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                  "Service": "ecs-tasks.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

#ECS
resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.ecs_cluster_name
  setting {
      name  = "containerInsights"
      value = "enabled" 
    }
}

resource "aws_ecs_task_definition" "ecs-task" {
  for_each = var.ecs_task_definition

  family = each.value.family
  requires_compatibilities = each.value.requires_compatibilities
  network_mode = each.value.network_mode
  cpu = each.value.cpu
  memory = each.value.memory
  container_definitions = each.value.container_definitions

  runtime_platform {
    operating_system_family = each.value.operating_system_family
    cpu_architecture = each.value.cpu_architecture
  }

  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}       

# Task that runs on Fargate
resource "aws_ecs_service" "ecs-service" { 
  for_each = var.ecs_task_definition
  name = each.value.service_name
  cluster = aws_ecs_cluster.ecs-cluster.id
  launch_type = var.launch_type
  task_definition = aws_ecs_task_definition.ecs-task[each.key].id

  platform_version = var.platform_version
  desired_count = var.desired_count
  

  network_configuration {
    assign_public_ip = true
    security_groups = var.security_id
    subnets = flatten([var.public_subnet])
  }
  
}

#Auto scaling for ECS services
resource "aws_appautoscaling_target" "as-target" {
  for_each = var.ecs_task_definition
  max_capacity = var.app_max_capacity
  min_capacity = var.app_min_capacity
  resource_id = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.ecs-service[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "cpuUtilization" {
  name = "cpu-utilzation-ecs"
  policy_type = "TargetTrackingScaling"
  for_each = var.ecs_task_definition
  resource_id = aws_appautoscaling_target.as-target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.as-target[each.key].scalable_dimension
  service_namespace = aws_appautoscaling_target.as-target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}