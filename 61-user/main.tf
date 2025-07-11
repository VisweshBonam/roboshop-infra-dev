resource "aws_lb_target_group" "user" {
  name     = "${var.project}-${var.environment}-user"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
 #When an instance is removed from the load balancer, Elastic Load Balancing waits (120 seconds) to let it finish active requests before fully stopping traffic to it
 deregistration_delay = 120
  health_check {
    healthy_threshold =2
    interval = 15
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }

}

resource "aws_instance" "user" {
  ami = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.user_sg_id]
  subnet_id = local.private_subnet_id
  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-user"
  })
}

resource "terraform_data" "user" {
  triggers_replace = [
    aws_instance.user.id
  ]

  provisioner "file" {
    source = "user.sh"
    destination = "/tmp/user.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.user.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
        "chmod +x /tmp/user.sh",
        "sudo sh /tmp/user.sh user ${var.environment}"

     ]
  }
}

resource "aws_ec2_instance_state" "user" {
  instance_id = aws_instance.user.id
  state = "stopped"
  depends_on = [ terraform_data.user ]
}

resource "aws_ami_from_instance" "user" {
  name = "${var.project}-${var.environment}-user"
  source_instance_id = aws_instance.user.id
  depends_on = [ aws_ec2_instance_state.user ]
}

resource "terraform_data" "user_delete" {
  triggers_replace = [
    aws_instance.user.id
  ]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.user.id}"
  }

  depends_on = [ aws_ami_from_instance.user ]
}

resource "aws_launch_template" "user" {
  name = "${var.project}-${var.environment}-user"
  image_id = aws_ami_from_instance.user.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
update_default_version = true 
  vpc_security_group_ids = [local.user_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
    {
        Name = "${var.project}-${var.environment}-user"
    })
  }
  
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
    {
        Name = "${var.project}-${var.environment}-user"
    })
  }

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-user"
  })

}




resource "aws_autoscaling_group" "user" {
  name                      = "${var.project}-${var.environment}-user"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = local.private_subnet_ids
 target_group_arns = [aws_lb_target_group.user.arn]

launch_template {
    id      = aws_launch_template.user.id
    version = aws_launch_template.user.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

 
  dynamic tag {
  for_each = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-user"
  })

  content {
    key = tag.key
    value = tag.value
    propagate_at_launch = true
  }
  }

  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_policy" "user" {
  name                   = "${var.project}-${var.environment}-user"
  policy_type        = "TargetTrackingScaling"
#   cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.user.name

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = local.backend_alb_arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn
  }

  condition {
    host_header {
      values = ["user.backend-dev.liveyourlife.site"]
    }
  }
}