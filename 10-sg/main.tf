module "frontend" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.frontend_sg_name
  sg_description = var.frontend_sg_description
}

module "bastian" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.bastian_sg_name
  sg_description = var.bastian_sg_description
}

module "backend_alb" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.backend_alb_sg_name
  sg_description = var.backend_alb_sg_description
}

module "frontend_alb" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = "frontend_alb"
  sg_description = "sg for frontend_alb"
}

module "vpn" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.vpn_sg_name
  sg_description = var.vpn_sg_description
}

module "mongodb" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.mongodb_sg_name
  sg_description = var.mongodb_sg_description
}

module "redis" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.redis_sg_name
  sg_description = var.redis_sg_description
}

module "mysql" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.mysql_sg_name
  sg_description = var.mysql_sg_description
}

module "rabbitmq" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.rabbitmq_sg_name
  sg_description = var.rabbitmq_sg_description
}

module "catalogue" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  vpc_id         = local.vpc_id
  sg_name        = var.catalogue_sg_name
  sg_description = var.catalogue_sg_description
}

module "user" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = "user"
  sg_description = "sg for user"
  vpc_id         = local.vpc_id
}

module "cart" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = "cart"
  sg_description = "sg for cart"
  vpc_id         = local.vpc_id
}

module "shipping" {
  source         = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = "shipping"
  sg_description = "sg for shipping"
  vpc_id         = local.vpc_id
}

module "payment" {
  source = "git::https://github.com/VisweshBonam/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "payment"
  sg_description = "sg for payment"
  vpc_id = local.vpc_id
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
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastian.sg_id #(normally we need to give bastion ip to allow connections from bastion, but as ip always change, we are giving bastion security group, so what ever instance create don that sg, will allow to connect port 80)
  # cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}

#vpn security-groups
# use to login to openvpn instance through ssh and configure the settings
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

#here users log in to download VPN config files and check configuration settings and from open vpn app, clients connect to the VPN over this port.
resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

#default vpn ports
resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

#default vpn ports
resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "backend_alb_vpn" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "mongodb_ssh_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_27017_vpn" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mongodb.sg_id
}

resource "aws_security_group_rule" "redis_ssh_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.redis.sg_id
}


resource "aws_security_group_rule" "mysql_ssh_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_ssh_3306" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mysql.sg_id
}



resource "aws_security_group_rule" "rabbitmq_ssh_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastian.sg_id
  security_group_id        = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.catalogue.sg_id
}


resource "aws_security_group_rule" "mongodb_catalogue" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id        = module.mongodb.sg_id
}

resource "aws_security_group_rule" "frontend_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

resource "aws_security_group_rule" "frontend_frontend_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id        = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.frontend.sg_id
}

resource "aws_security_group_rule" "backend_alb_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id        = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "cart_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "user_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.user.sg_id
}

resource "aws_security_group_rule" "mongodb_user" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.mongodb.sg_id
}

resource "aws_security_group_rule" "redis_6379_vpn" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.redis.sg_id
}

resource "aws_security_group_rule" "redis_user" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.redis.sg_id
}

resource "aws_security_group_rule" "user_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.user.sg_id
}

resource "aws_security_group_rule" "user_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.user.sg_id
}


resource "aws_security_group_rule" "cart_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.cart.sg_id
}




resource "aws_security_group_rule" "redis_cart" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.redis.sg_id
}

resource "aws_security_group_rule" "backend_alb_cart" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.backend_alb.sg_id
}


resource "aws_security_group_rule" "mysql_shipping" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.mysql.sg_id
}

resource "aws_security_group_rule" "shipping_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.shipping.sg_id
}

resource "aws_security_group_rule" "backend_alb_shipping" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "payment_vpn_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_ssh_http" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_backend_alb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "backend_alb_payment" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" {
  type = "ingress"
  from_port = 5672
  to_port = 5672
  protocol = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.rabbitmq.sg_id
}

