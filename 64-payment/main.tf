resource "aws_lb_target_group" "payment" {
  name                 = "${var.project}-${var.environment}-payment"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 120
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = 8080
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    matcher             = "200-299"
  }
}

resource "aws_instance" "payment" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-payment"
  })
}


resource "terraform_data" "payment" {
  triggers_replace = [
    aws_instance.payment.id
  ]

  provisioner "file" {
    source      = "payment.sh"
    destination = "/tmp/payment.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.payment.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/payment.sh",
      "sudo /tmp/payment.sh payment ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "payment" {
  instance_id = aws_instance.payment.id
  state       = "stopped"
  depends_on  = [terraform_data.payment]
}

resource "aws_ami_from_instance" "payment" {
  name               = "${var.project}-${var.environment}-payment"
  source_instance_id = aws_instance.payment.id
  depends_on         = [aws_ec2_instance_state.payment]

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-payment"
  })
}

resource "terraform_data" "payment_delete" {
  triggers_replace = [
    aws_instance.payment.id
  ]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.payment.id}"
  }

  depends_on = [aws_ami_from_instance.payment]
}

resource "aws_launch_template" "payment" {
  name                                 = "${var.project}-${var.environment}-payment"
  image_id                             = aws_ami_from_instance.payment.id
  instance_type                        = "t3.micro"
  update_default_version               = true
  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [local.sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-payment"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-payment"
    })
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-payment"
  })

}


resource "aws_autoscaling_group" "payment" {
  min_size = 1
  max_size = 10
  desired_capacity = 2
  health_check_grace_period = 120
  health_check_type = "ELB"
  vpc_zone_identifier = local.private_subnet_ids

  target_group_arns = [aws_lb_target_group.payment.arn]

   launch_template {
    id      = aws_launch_template.payment.id
    version = aws_launch_template.payment.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags,
    {
        Name = "${var.project}-${var.environment}-payment"
    })

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true 
    }
  }
}


resource "aws_autoscaling_policy" "payment" {
  name = "${var.project}-${var.environment}-payment"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.payment.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "payment" {
  listener_arn = local.backend_alb_arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payment.arn
  }

  condition {
    host_header {
      values = ["payment.backend-dev.liveyourlife.site"]
    }
  }
}