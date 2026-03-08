module "sg" {
    source = "../../terraform-aws-sg-module/"
    project = var.project
    environment = var.environment
    sg_name = "mongodb"
    vpc_id = local.vpc_id
}