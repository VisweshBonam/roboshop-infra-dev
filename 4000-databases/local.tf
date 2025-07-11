locals {
  ami_id             = data.aws_ami.joindevops.id
  mongodb_sg_id      = data.aws_ssm_parameter.mongodb_sg_id.value
  database_subnet_id = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
  common_tags = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = true
  }
}
