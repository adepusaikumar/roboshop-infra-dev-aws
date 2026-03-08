locals {
  ami_id = data.aws_ami.joindevops.id
  common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
    database_subnet_id = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
    mongodb_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
}