module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"
   version = "9.16.0"  #latest version is not supporting for our provider, so we take before version
  name    = "${var.project}-${var.environment}-backend-alb"
  internal = true # default in module they give false(means created for public alb)
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids

  create_security_group = false  #(if u need to create here , u can give true and enable rules from open source)

  security_groups = [local.backend_alb_sg_id]

  enable_deletion_protection = false

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-backend_alb"
  })
}

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Fixed response content</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  name = "*.backend-${var.environment}.${var.zone_name}"
  type = "A"
  zone_id = var.zone_id

  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id # This is the ZONE ID of ALB
    evaluate_target_health = true
  }
}