locals {
  common_tags = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = true
  }
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  backend_alb_sg_id  = data.aws_ssm_parameter.backend_alb_sg_id.value
}
