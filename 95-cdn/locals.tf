locals {
    CachingDisabled = data.aws_cloudfront_cache_policy.CachingDisabled.id
    CachingOptimized = data.aws_cloudfront_cache_policy.CachingOptimized.id
    aws_acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }

    
}