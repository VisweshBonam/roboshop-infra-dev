locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  ami_id = data.aws_ami.ami_id.id
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  frontend_alb_arn = data.aws_ssm_parameter.frontend_alb_arn.value

  frontend_sg_id = data.aws_ssm_parameter.frontend_sg_id.value

  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}