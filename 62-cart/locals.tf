locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  ami_id = data.aws_ami.roboshop.id
  cart_sg_id = data.aws_ssm_parameter.cart_sg_id.value
  backend_alb_arn = data.aws_ssm_parameter.backend_alb_arn.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}