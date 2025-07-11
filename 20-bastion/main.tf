resource "aws_instance" "bastion" {
  
  ami = data.aws_ami.ami_id.id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.bastian_sg_id]

   subnet_id   = local.public_subnet_id
  tags = merge(var.bastian_tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-bastion"
  })
}