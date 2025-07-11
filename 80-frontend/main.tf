resource "aws_lb_target_group" "frontend_alb" {
  name                 = "${var.project}-${var.environment}-frontend-alb"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 120
  health_check {
    healthy_threshold = 2
    interval          = 15
    matcher           = "200-299"
    path              = "/health"
    port              = 80
    # protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 2

  }
}

resource "aws_instance" "frontend" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.frontend_sg_id]
  subnet_id              = local.private_subnet_id
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
  })
}

resource "terraform_data" "frontend" {
  triggers_replace = [
    aws_instance.frontend.id
  ]

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.frontend.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh frontend ${var.environment}"
    ]
  }


}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend.id
  state       = "stopped"
  depends_on  = [terraform_data.frontend]
}

resource "aws_ami_from_instance" "frontend" {
  name               = "${var.project}-${var.environment}-frontend"
  source_instance_id = aws_instance.frontend.id

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
  })

  depends_on = [aws_ec2_instance_state.frontend]
}

resource "terraform_data" "frontend_del_instance" {
  triggers_replace = [
    aws_instance.frontend.id
  ]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.frontend.id}"
  }

  depends_on = [aws_ami_from_instance.frontend]
}

resource "aws_launch_template" "frontend" {
  name                                 = "${var.project}-${var.environment}-frontend"
  image_id                             = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate" # when autoscaling is removing instances,when traffic decreases,it should terminate,not stop
  instance_type                        = "t3.micro"
  vpc_security_group_ids               = [local.frontend_sg_id]
  update_default_version               = true

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-frontend"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-frontend"
    })
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
  })
}

resource "aws_autoscaling_group" "frontend" {
  name                      = "${var.project}/${var.environment}-frontend"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  target_group_arns         = [aws_lb_target_group.frontend_alb.arn]

  vpc_zone_identifier = local.private_subnet_ids


  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  dynamic "tag" {
    for_each = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-frontend"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_policy" "frontend" {
  name        = "${var.project}-${var.environment}-frontend"
  policy_type = "TargetTrackingScaling"
  #   cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.frontend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = local.frontend_alb_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb.arn
  }

  condition {
    host_header {
      values = ["dev.liveyourlife.site"]
    }
  }
}
