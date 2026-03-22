resource "aws_lb" "frontend_alb" {
    name               = "${var.project}-${var.environment}-frontend"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [local.frontend_alb_sg_id]
    subnets            = local.public_subnet_ids

    # just to delete from terraform mentioning as false
    enable_deletion_protection = false

    tags = merge(
    {
        Name = "${var.project}-${var.environment}-frontend"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.frontend_alb_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>This content is coming from default FrontEnd ALB Rule</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name    = "*.${var.domain_name}" #*.rajudevops.online
  type    = "A"
  allow_overwrite = true

  # load balancer details
  alias {
    name                   = aws_lb.frontend_alb.dns_name
    zone_id                = aws_lb.frontend_alb.zone_id
    evaluate_target_health = true
  }
}