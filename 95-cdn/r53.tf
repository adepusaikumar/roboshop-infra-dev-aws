resource "aws_route53_record" "cdn" {
  zone_id = var.zone_id
  name    = "${var.project}-${var.environment}.${var.domain_name}" #roboshop-dev.rajudevops.online
  type    = "A"
  allow_overwrite = true

  # load balancer details
  alias {
    name                   = aws_cloudfront_distribution.roboshop.domain_name
    zone_id                = aws_cloudfront_distribution.roboshop.hosted_zone_id
    evaluate_target_health = true
  }
}