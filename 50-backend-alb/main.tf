resource "aws_lb" "backend_alb" {
    name               = "${var.project}-${var.environment}"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [local.backend_alb_sg_id]
    subnets            = local.private_subnet_ids

    # just to delete from terraform mentioning as false
    enable_deletion_protection = false

    tags = merge(
    {
        Name = "${var.project}-${var.environment}"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>This content is coming from default backend ALB Rule</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend-alb-${var.environment}.${var.domain_name}" #*.backend-alb-dev.rajudevops.online
  type    = "A"
  allow_overwrite = true
  

  # load balancer details
  alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
    
  }
}