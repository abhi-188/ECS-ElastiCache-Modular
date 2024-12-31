variable "environment" {
  
}

variable "vpc_cidr_base" {
  description = "The CIDR block of the vpc"
  
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  
}
variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  
}
variable "region" {
  
}
variable "app_name" {
  
}
variable "availability_zones" {
  
}


variable "ecs_cluster_name" {
  type = string
}

variable "ecs_task_definition" {
  type = map(any)
}

variable "launch_type" {

}

variable "platform_version" {

}

variable "desired_count" {

}

variable "app_max_capacity" {

}

variable "app_min_capacity" {

}


variable "ec-subnet_group_name" {

}

variable "ec-parameter_group_name" {

}

variable "ec-parameter_group_family" {

}

variable "ec-cluster_id" {

}



variable "ec-cluster_engine_version" {

}

variable "ec-cluster_node_type" {

}

variable "replication_group_id" {
  type = string
}

variable "automatic_failover_enabled" {
  type = bool
}

variable "num_node_groups" {
  type = number
}

variable "replicas_per_node_group" {
  type = number
}

