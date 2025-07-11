
# create frontend-load balancer
module "frontend_alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.project}-${var.environment}-frontend-alb" #roboshop-dev-frontend-alb
  version                    = "9.16.0"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  internal                   = false
  create_security_group      = false
  security_groups            = [local.frontend_alb_sg_id]
  enable_deletion_protection = false


  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend-alb"
  })
}

# create listner and attach to frontend-alb which allow only 443 https
resource "aws_lb_listener" "front_end_alb" {
  load_balancer_arn = module.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello , I am from frontend-alb using HTTPS</h1>"
      status_code  = "200"
    }
  }

}

resource "aws_route53_record" "front_end_alb" {
zone_id = var.zone_id
type = "A"
name = "dev.${var.zone_name}"  # *.liveyourlife.site 

alias {
    name                   = module.frontend_alb.dns_name
    zone_id                = module.frontend_alb.zone_id
    evaluate_target_health = true
  }
}
