#open source module, directly from terraform

module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.16.0"
  name    = "${var.project}-${var.environment}-backend-llb"
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids #(for load balancer , we to assign min 2 subnets)
  
  create_security_group = false #(if we already create security group, make it as false)
  internal = true #(default they will create public lb means=false, but now we are creating private alb = so true)

  security_groups = [local.backend_alb_sg_id]

  enable_deletion_protection = false  #(to enable delete , which destroying or updating)


  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-backend-llb"
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


#attaching alb DNS name to route53 record
resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend-dev.${var.zone_name}"
  type    = "A"

  alias {
    name                   = module.backend_alb.dns_name # This is the DNS_NAME of ALB (we can find it in open module of alb outputs, because we use open source alb to create load balnacer)
    zone_id                = module.backend_alb.zone_id # This is the ZONE ID of ALB
    evaluate_target_health = true
  }
}