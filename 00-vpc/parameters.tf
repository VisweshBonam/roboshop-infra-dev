resource "aws_ssm_parameter" "vpc" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnets_ids)
}

resource "aws_ssm_parameter" "private_subnets_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnets_ids)
}

resource "aws_ssm_parameter" "database_subnets_ids" {
  name  = "/${var.project}/${var.environment}/database_subnets_ids"
  type  = "StringList"
  value = join(",", module.vpc.database_subnets_ids)
}