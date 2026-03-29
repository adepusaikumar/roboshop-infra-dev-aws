resource "aws_cloudfront_distribution" "roboshop" {
  origin {
    # Frontend URL : frontend-dev.rajudevops.online
    domain_name              = "frontend-${var.environment}.${var.domain_name}"
    origin_id                = "frontend-${var.environment}.${var.domain_name}"

    custom_origin_config {
      http_port              = 80 // Required to be set but not used
      https_port             = 443
      origin_protocol_policy = "https-only" # Use "http-only" or "match-viewer" if needed
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
     }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Roboshop Dev CDN Distribution for ALB"

  # CDN URL : roboshop-dev.rajudevops.online
  aliases = ["${var.project}-${var.environment}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "https-only"
    cache_policy_id        = local.CachingDisabled
    
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/media/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"

     viewer_protocol_policy = "https-only"
    cache_policy_id = local.CachingOptimized
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   =["GET", "HEAD", "OPTIONS"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "https-only"
    cache_policy_id = local.CachingOptimized
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-frontend"
    },
    local.common_tags
  )

  viewer_certificate {
    acm_certificate_arn = local.aws_acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}