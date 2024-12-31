module "vpc" {
  source               = "../modules/vpc"
  environment          = var.environment
  vpc_cidr_base        = var.vpc_cidr_base
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  region               = var.region
  availability_zones   = var.availability_zones
  app_name             = var.app_name
}


module "ecs" {
  source              = "../modules/ECS"
  vpc_id              = module.vpc.vpc_id
  security_id         = module.vpc.ecs_security_groups_id
  public_subnet       = module.vpc.public_subnets_id
  ecs_cluster_name    = var.ecs_cluster_name
  ecs_task_definition = var.ecs_task_definition
  launch_type         = var.launch_type
  platform_version    = var.platform_version
  desired_count       = var.desired_count

  app_max_capacity = var.app_max_capacity
  app_min_capacity = var.app_min_capacity
}


module "ec-redis" {
  source                    = "../modules/ElasticCache"
  private_subnet_ids        = module.vpc.private_subnets_id
  ec-subnet_group_name      = var.ec-subnet_group_name
  ec-parameter_group_name   = var.ec-parameter_group_name
  ec-parameter_group_family = var.ec-parameter_group_name
  ec-cluster_id             = var.ec-cluster_id
  ec-cluster_engine_version = var.ec-cluster_engine_version
  ec-cluster_node_type      = var.ec-cluster_node_type

  replication_group_id       = var.replication_group_id
  automatic_failover_enabled = var.automatic_failover_enabled
  num_node_groups            = var.num_node_groups
  replicas_per_node_group    = var.replicas_per_node_group
}