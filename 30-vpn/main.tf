resource "aws_key_pair" "open_vpn" {
  key_name   = "open_vpn"
  public_key = file("E:\\devops\\vishu\\open-vpn.pub")  # for mac use /
}


resource "aws_instance" "open-vpn" {
  ami = local.vpn_ami_id
  instance_type = var.instance_type
  subnet_id = local.public_subnets_id
  vpc_security_group_ids = [local.vpn_sg_id]
  key_name = "open_vpn"   #(if u have key in aws account)
  # key_name = aws_key_pair.open_vpn.key_name

  user_data = file("openvpn.sh") #(we can login to the instance through ssh and configure, if not will give script in "openvpn.ssh" and configure it)
  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-open-vpn"
  })

  }

  resource "aws_route53_record" "open_vpn" {
    zone_id = var.zone_id
    name = "open-vpn.${var.zone_name}"
    type = "A"
    ttl = 1
    records = [aws_instance.open-vpn.public_ip]
  }