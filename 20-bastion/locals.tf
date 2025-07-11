locals {
  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }

  bastian_sg_id = data.aws_ssm_parameter.bastion_sg_id.value

  public_subnet_id = split(",",data.aws_ssm_parameter.public_subnet_ids.value)[0]
}

# output "bastian_oup" {
#   value = local.bastian_sg_id
# }