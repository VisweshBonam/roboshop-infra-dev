resource "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project}/${var.environment}/vpn_sg_id"
  type = "String"
  value = module.vpn.sg_id
}

resource "aws_ssm_parameter" "backend_alb_sg_id" {
  name = "/${var.project}/${var.environment}/backend_alb_sg_id"
  type = "String"
  value = module.backend_alb.sg_id
}

resource "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project}/${var.environment}/mongodb_sg_id"
  type = "String"
  value = module.mongodb.sg_id
}

resource "aws_ssm_parameter" "catalogue_sg_id" {
  name = "/${var.project}/${var.environment}/catalogue_sg_id"
  type = "String"
  value = module.catalogue.sg_id
}