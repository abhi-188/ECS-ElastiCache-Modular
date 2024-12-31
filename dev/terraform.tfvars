environment          = "ecs-dev"
vpc_cidr_base        = "10.7.0.0/16"
public_subnets_cidr  = ["10.7.1.0/24", "10.7.2.0/24"]
private_subnets_cidr = ["10.7.3.0/24", "10.7.4.0/24"]
region               = "us-east-2"
availability_zones   = ["us-east-2a", "us-east-2b"]
app_name             = "test"


ecs_cluster_name = "ecs-cluster"
ecs_task_definition = {
  Lion-API = {
    family                   = "linux-task"
    requires_compatibilities = ["FARGATE"],
    network_mode             = "awsvpc",
    service_name             = "Lion-API",
    cpu                      = 1024,
    memory                   = 2048,
    operating_system_family  = "LINUX"
    cpu_architecture         = "X86_64"
    container_definitions    = <<TASK_DEFINATION
        [
            {
                "name"  : "nginx",
                "image" : "public.ecr.aws/nginx/nginx:alpine-slim",
                "memory" : 500,
                "cpu"    : 120,
                "essential":true,
                "portMappings" : [
                    {
                        "containerPort" : 80,
                        "hostPort"      : 80
                    }
                ]
            }
            
        ]
        TASK_DEFINATION
  }
}
launch_type      = "FARGATE"
platform_version = "LATEST"
desired_count    = "1"

app_max_capacity = 3
app_min_capacity = 1


# Redis ec variables
ec-subnet_group_name      = "ec-sg"
ec-parameter_group_name   = "default.redis7.cluster.on"
ec-parameter_group_family = "redis7"
ec-cluster_id             = "ec-redis-cluster"
ec-cluster_engine_version = "7.1"
ec-cluster_node_type      = "cache.t4g.micro"

replication_group_id       = "ec-rg"
automatic_failover_enabled = true
num_node_groups            = 1
replicas_per_node_group    = 2