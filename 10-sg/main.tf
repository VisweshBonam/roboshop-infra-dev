module "frontend" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.frontend_sg_name}"
  sg_description = var.frontend_sg_description
}

module "bastian" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.bastian_sg_name}"
  sg_description = var.bastian_sg_description
}

module "backend_alb" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.backend_alb_sg_name}"
  sg_description = var.backend_alb_sg_description
}

module "vpn" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.vpn_sg_name}"
  sg_description = var.vpn_sg_description
}

module "mongodb" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.mongodb_sg_name}"
  sg_description = var.mongodb_sg_description
}

module "redis" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.redis_sg_name}"
  sg_description = var.redis_sg_description
}

module "mysql" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.mysql_sg_name}"
  sg_description = var.mysql_sg_description
}

module "rabbitmq" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.rabbitmq_sg_name}"
  sg_description = var.rabbitmq_sg_description
}

module "catalogue" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "${var.project}-${var.environment}-${var.catalogue_sg_name}"
  sg_description = var.catalogue_sg_description
}




#bastian accepting connections from laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastian.sg_id
}

#backend alb accepting connections from bastion host on port 80
resource "aws_security_group_rule" "backend_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastian.sg_id  #(normally we need to give bastion ip to allow connections from bastion, but as ip always change, we are giving bastion security group, so what ever instance create don that sg, will allow to connect port 80)
  # cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}

# opening port
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "backend_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "mongodb_ssh_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_27017_vpn" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.mongodb.sg_id
}

resource "aws_security_group_rule" "redis_ssh_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.redis.sg_id
}


resource "aws_security_group_rule" "mysql_ssh_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.mysql.sg_id
}


resource "aws_security_group_rule" "rabbitmq_ssh_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id  
  security_group_id = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_http" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastian.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_backend_alb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.catalogue.sg_id
}


resource "aws_security_group_rule" "mongodb_catalogue" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id = module.mongodb.sg_id
}







