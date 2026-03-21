resource "aws_ssm_parameter" "backned_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/backend_alb_listener_arn"
  type = String
  value = aws_lb.backend_alb.arn
}