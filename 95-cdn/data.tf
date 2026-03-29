
data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_ssm_parameter" "aws_acm_certificate_arn" {
  name = "/${var.project}/${var.environment}/frontend_alb_certificate_arn"
}