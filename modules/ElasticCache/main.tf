resource "aws_elasticache_subnet_group" "ec-sg" {
  name       = var.ec-subnet_group_name
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "ec-rg" {
  replication_group_id       = var.replication_group_id
  description                = "example description"
  node_type                  = var.ec-cluster_node_type
  port                       = 6379
  parameter_group_name       = var.ec-parameter_group_name
  subnet_group_name          = aws_elasticache_subnet_group.ec-sg.name
  automatic_failover_enabled = true

  num_node_groups         = var.num_node_groups         ##No of shards
  replicas_per_node_group = var.replicas_per_node_group ## No of node  in each shard

  engine_version = var.ec-cluster_engine_version
  engine         = "redis"
}


