locals {
  ami_id = data.aws_ami.joindevops.id
  database_subnet_id = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  vpn_sg_id = data.aws_ssm_parameter.vpn_sg_id.value
  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}