module "sg" {
    count = length(var.sg_names)
    # source = "../../terraform-aws-sg-module/"
    source = "git::https://github.com/adepusaikumar/terraform-aws-sg-module.git?ref=main"
    project = var.project
    environment = var.environment
    # sg_name = var.sg_names[count.index]
    sg_name = replace(var.sg_names[count.index], "_", "-")
    vpc_id = local.vpc_id
}