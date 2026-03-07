module "vpc" {
    source = "git::https://github.com/adepusaikumar/terraform-aws-vpc-module.git"
    environment = var.environment
    project = var.project
    is_peering_required = true
}