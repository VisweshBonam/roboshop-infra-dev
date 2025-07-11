locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  ami_id = data.aws_ami.joindevops.id

  catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value

  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]

   common_tags = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = true
  }
}