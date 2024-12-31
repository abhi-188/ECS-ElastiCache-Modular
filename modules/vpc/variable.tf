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
