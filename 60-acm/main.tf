
# creating acm certificate for frontend HTTPS
resource "aws_acm_certificate" "liveyourlife" {
  domain_name       = "*.${var.zone_name}"  # *.liveyourlife.site
  validation_method = "DNS" # we can validate through email also, but dns validate in aws itself

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# create Route53 record for above DNS for verfication

resource "aws_route53_record" "liveyourlife" {
  for_each = {
    for dvo in aws_acm_certificate.liveyourlife.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id  # we just need to give zone_id, remianing it will take care and create
}

# need to click validate button for to validate DNS Record
# it will validate the records created for certificate

resource "aws_acm_certificate_validation" "liveyourlife" {  
  certificate_arn         = aws_acm_certificate.liveyourlife.arn
  validation_record_fqdns = [for record in aws_route53_record.liveyourlife : record.fqdn]
}