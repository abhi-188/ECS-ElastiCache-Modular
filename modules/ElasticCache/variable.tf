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

variable "private_subnet_ids" {

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