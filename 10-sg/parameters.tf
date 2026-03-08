resource "aws_ssm_parameter" "sg_id" {
  type = "String"
  name = "/${var.project}/${var.environment}/sg_id"
  value = module.sg.sg_id
}