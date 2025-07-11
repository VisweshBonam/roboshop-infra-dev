resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-299"
    path                = "/health" # developers check whether health or not by hitting http::/<domain-name>:8080/health
    port                = 8080
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
}

resource "aws_instance" "catalogue" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
  })
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
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
  depends_on  = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue]

  # tags = merge(local.common_tags,
  # {
  #   Name = "${var.project}-${var.environment}-catalogue"
  # })
}

resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }

  depends_on = [aws_ami_from_instance.catalogue]
}

resource "aws_launch_template" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  update_default_version = true
  vpc_security_group_ids = [local.catalogue_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
    })
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
  })

}









