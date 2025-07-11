resource "aws_lb_target_group" "shipping" {
  name     = "${var.project}-${var.environment}-shipping"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  #When an instance is removed from the load balancer, Elastic Load Balancing waits (90 seconds) to let it finish active requests before fully stopping traffic to it
  deregistration_delay = 90

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = 8080
    interval            = 10
    timeout             = 5
    matcher             = "200-299"
    path                = "/health"
    protocol            = "HTTP"

  }
}

resource "aws_instance" "shipping" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-shipping"
  })
}

resource "terraform_data" "shipping" {
  triggers_replace = [
    aws_instance.shipping.id
  ]

  provisioner "file" {
    source      = "shipping.sh"
    destination = "/tmp/shipping.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.shipping.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/shipping.sh",
      "sudo sh /tmp/shipping.sh shipping ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "shipping" {
  instance_id = aws_instance.shipping.id
  state       = "stopped"
  depends_on  = [terraform_data.shipping]
}

resource "aws_ami_from_instance" "shipping" {
  name               = "${var.project}-${var.environment}-shipping"
  source_instance_id = aws_instance.shipping.id
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-shipping"
  })

  depends_on = [aws_ec2_instance_state.shipping]
}

resource "terraform_data" "delete_shipping" {
  triggers_replace = [
    aws_instance.shipping.id
  ]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.shipping.id}"
  }

  depends_on = [aws_ami_from_instance.shipping]
}

resource "aws_launch_template" "shipping" {
  name                                 = "${var.project}-${var.environment}-shipping"
  image_id                             = aws_ami_from_instance.shipping.id
  instance_type                        = "t3.micro"
  vpc_security_group_ids               = [local.sg_id]
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true 
  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-shipping"
    })
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-shipping"
    })
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-shipping"
  })

}

resource "aws_autoscaling_group" "shipping" {
  name                      = "${var.project}-${var.environment}-shipping"
  min_size                  = 1
  max_size                  = 10
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 120
  vpc_zone_identifier = local.private_subnet_ids
  target_group_arns = [aws_lb_target_group.shipping.arn]


  launch_template {
    id      = aws_launch_template.shipping.id
    version = aws_launch_template.shipping.latest_version
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
        Name = "${var.project}-${var.environment}-shipping"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "shipping" {
  name = "${var.project}-${var.environment}-shipping"
  autoscaling_group_name = aws_autoscaling_group.shipping.name

  policy_type = "TargetTrackingScaling"

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
  
}

resource "aws_lb_listener_rule" "shipping" {
  listener_arn = local.backend_alb_arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shipping.arn
  }

  condition {
    host_header {
      values = ["shipping.backend-dev.liveyourlife.site"]
    }
  }
}