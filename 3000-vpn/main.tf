resource "aws_key_pair" "open_vpn" {
  key_name   = "open_vpn"
  public_key = file("E:\\devops\\vishu\\open-vpn.pub")  # for mac use /
}


resource "aws_instance" "vpn" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.vpn_sg_id]
  key_name               = aws_key_pair.open_vpn.key_name
  user_data = file("openvpn.sh")

  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-vpn"
  })
}
