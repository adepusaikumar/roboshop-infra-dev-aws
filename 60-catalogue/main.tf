resource "aws_instance" "catalogue" {
  ami = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id = local.private_subnet_id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  depends_on = [ aws_ami_from_instance.catalogue ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source = "./bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on = [ aws_instance.catalogue ]
}

resource "aws_ami_from_instance" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ]
  tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name        = "${var.project}-${var.environment}-catalogue"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id

  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 3
    interval = 10
    path = "/health"
    matcher = "200-299"
    timeout = 2
    protocol = "HTTP"

  }
}

resource "aws_launch_template" "catalogue" {
  name        = "${var.project}-${var.environment}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id

  vpc_security_group_ids = [local.catalogue_sg_id]

  # each time we apply terraform this version will be updated as default
  update_default_version = true

  # once autoscaling sees less traffic, it will terminate the instance
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"

# tags for instances created by launch template through autoscaling
  tag_specifications {
    resource_type = "instance"

  tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
  }

  # tags for instances created by launch template through autoscaling
  tag_specifications {
    resource_type = "volume"

  tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
  }
}

resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project}-${var.environment}-catalogue"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 4
  health_check_grace_period = 120
  health_check_type         = "ELB"
  force_delete              = false

  # launch template block to refer the launch template created above
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]
  target_group_arns = aws_lb_target_group.catalogue.arn

  # with in 15min autoscaling should be successful
  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}