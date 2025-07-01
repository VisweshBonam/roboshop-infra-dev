variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "frontend_sg_name" {
  default = "frontend"
}

variable "frontend_sg_description" {
  default = "Creating security group for frontend"
}

variable "bastian_sg_name" {
  default = "bastian"
}

variable "bastian_sg_description" {
  default = "Creating security group for bastian"
}

variable "backend_alb_sg_name" {
  default = "backend-alb"
}

variable "backend_alb_sg_description" {
  default = "created security group for backend-alb"
}

variable "vpn_sg_name" {
  default = "vpn"
}

variable "vpn_sg_description" {
  default = "Creating security group for vpn"
}

variable "mongodb_sg_name" {
  default = "mongodb"
}

variable "mongodb_sg_description" {
  default = "Creating security group for mongodb"
}

variable "redis_sg_name" {
  default = "redis"
}

variable "redis_sg_description" {
  default = "Creating security group for redis"
}

variable "mysql_sg_name" {
  default = "mysql"
}

variable "mysql_sg_description" {
  default = "Creating security group for mysql"
}

variable "rabbitmq_sg_name" {
  default = "rabbitmq"
}

variable "rabbitmq_sg_description" {
  default = "Creating security group for rabbitmq"
}

variable "catalogue_sg_name" {
  default = "catalogue"
}

variable "catalogue_sg_description" {
  default = "Creating security group for catalogue"
}