provider "aws" { region = "us-east-1" }
variable "vpc_id" { default = "vpc-0458b076218d5f15d" }
variable "subnet_az1_id" { default = "subnet-0eff32e6678035c1b" }
variable "subnet_az2_id" { default = "subnet-00982afe357bcc225" }

resource "aws_security_group" "samba_ad_sg" {
  name        = "samba-ad-dc-sg"
  description = "SG para Samba 4 AD DC (sem DNS interno)"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "keycloak_sg" {
  name        = "keycloak-sg"
  description = "SG para Keycloak"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "samba_dc1" {
  ami                  = "ami-0c7217cdde317cfec"
  instance_type        = "t3.medium"
  subnet_id            = var.subnet_az1_id
  vpc_security_group_ids = [aws_security_group.samba_ad_sg.id]
  tags = { Name = "samba-ad-dc-1" Role = "samba-dc-primary" }
}

resource "aws_instance" "samba_dc2" {
  ami                  = "ami-0c7217cdde317cfec"
  instance_type        = "t3.medium"
  subnet_id            = var.subnet_az2_id
  vpc_security_group_ids = [aws_security_group.samba_ad_sg.id]
  tags = { Name = "samba-ad-dc-2" Role = "samba-dc-replica" }
}

resource "aws_instance" "keycloak" {
  ami                  = "ami-0c7217cdde317cfec"
  instance_type        = "t3.medium"
  subnet_id            = var.subnet_az1_id
  vpc_security_group_ids = [aws_security_group.keycloak_sg.id]
  tags = { Name = "keycloak-server" Role = "keycloak-server" }
}

resource "aws_route53_zone" "private_zone" {
  name = "empresa.local"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "dc1" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "dc1.empresa.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.samba_dc1.private_ip]
}

resource "aws_route53_record" "dc2" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "dc2.empresa.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.samba_dc2.private_ip]
}

resource "aws_route53_record" "ad_domain" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "ad.empresa.local"
  type    = "A"
  ttl     = 60
  records = [aws_instance.samba_dc1.private_ip, aws_instance.samba_dc2.private_ip]
}

resource "aws_route53_record" "sso" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "sso.empresa.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.keycloak.private_ip]
}
