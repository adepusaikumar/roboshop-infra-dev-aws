resource "aws_acm_certificate" "roboshop_frontend" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-${var.domain_name}"
    },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "roboshop_frontend" {
  for_each = {
    for dvo in aws_acm_certificate.roboshop_frontend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "roboshop_frontend" {
  certificate_arn         = aws_acm_certificate.roboshop_frontend.arn
  validation_record_fqdns = [for record in aws_route53_record.roboshop_frontend : record.fqdn]
}