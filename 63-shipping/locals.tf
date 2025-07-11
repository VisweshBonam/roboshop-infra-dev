locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  ami_id = data.aws_ami.roboshop.id
  sg_id = data.aws_ssm_parameter.shipping_sg_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  backend_alb_arn = data.aws_ssm_parameter.backend_alb_arn.value

  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}