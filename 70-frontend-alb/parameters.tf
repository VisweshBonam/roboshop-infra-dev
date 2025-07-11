resource "aws_ssm_parameter" "frontend_alb_arn" {
  name = "/${var.project}/${var.environment}/frontend_alb_arn"
  type = "String"
  value = aws_lb_listener.front_end_alb.arn
}