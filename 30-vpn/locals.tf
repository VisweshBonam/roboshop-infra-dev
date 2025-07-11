locals {
  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }

  vpn_ami_id = data.aws_ami.open_vpn.id
  public_subnets_id = split("," , data.aws_ssm_parameter.public_subnet_ids.value)[0]
  vpn_sg_id = data.aws_ssm_parameter.vpn_sg_id.value
}