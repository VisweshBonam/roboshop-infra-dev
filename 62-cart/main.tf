resource "aws_lb_target_group" "cart" {
  name                 = "${var.project}-${var.environment}-cart"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 120

  health_check {
     healthy_threshold   = 2
     interval            = 10
     matcher             = "200-299"
     path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2

  }
}

resource "aws_instance" "cart" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.cart_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-cart"
  })

}

resource "terraform_data" "cart" {
  triggers_replace = [
    aws_instance.cart.id
  ]

  provisioner "file" {
    source      = "cart.sh"
    destination = "/tmp/cart.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.cart.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/cart.sh",
      "sudo sh /tmp/cart.sh cart ${var.environment}"
    ]

  }
}

resource "aws_ec2_instance_state" "cart" {
  instance_id = aws_instance.cart.id
  state       = "stopped"
  depends_on  = [terraform_data.cart]
}

resource "aws_ami_from_instance" "cart" {
  name               = "${var.project}-${var.environment}-cart"
  source_instance_id = aws_instance.cart.id
  depends_on         = [aws_ec2_instance_state.cart]
}



resource "terraform_data" "cart_delete" {
     triggers_replace = [
    aws_instance.cart.id
  ]
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.cart.id}"
  }
  depends_on = [aws_ami_from_instance.cart]
}

resource "aws_launch_template" "cart" {
  name                                 = "${var.project}-${var.environment}-cart"
  instance_type                        = "t3.micro"
  vpc_security_group_ids               = [local.cart_sg_id]
  image_id                             = aws_ami_from_instance.cart.id
  instance_initiated_shutdown_behavior = "terminate"

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-cart"
    })
  }
  update_default_version = true 
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-cart"
    })
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-cart"
  })
}


resource "aws_autoscaling_group" "cart" {
  name                      = "${var.project}-${var.environment}-cart"
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 90
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = local.private_subnet_ids

  target_group_arns = [aws_lb_target_group.cart.arn]

     launch_template {
    id      = aws_launch_template.cart.id
    version = aws_launch_template.cart.latest_version
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

  dynamic tag {
    for_each = merge(local.common_tags,
    {
        Name = "${var.project}-${var.environment}-cart"
    })
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true 
    }
  }
}

resource "aws_autoscaling_policy" "cart" {
  name                   = "${var.project}-${var.environment}-cart"
  policy_type        = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.cart.name

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "cart" {
  listener_arn = local.backend_alb_arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cart.arn
  }

  condition {
    host_header {
      values = ["cart.backend-dev.liveyourlife.site"]
    }
  }
}

