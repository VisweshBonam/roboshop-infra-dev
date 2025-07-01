locals {
  ami_id = data.aws_ami.ami_id.id
  database_subnets_ids = split(",",data.aws_ssm_parameter.database_subnets_ids.value)[0]
  mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id.value
  redis_sg_id = data.aws_ssm_parameter.redis_sg_id.value
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
  rabbitmq_sg_id = data.aws_ssm_parameter.rabbitmq_sg_id.value

  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}