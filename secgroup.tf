resource "aws_security_group" "vprofile-bean-elb-sg" {
  name        = "vprofile-bean-elb-sg"
  description = "security group for vprofile-bean-elb"
  vpc_id      = module.vpc.vpc_id # reference to the VPC module

  tags = {
    Name    = "vprofile-bean-elb"
    MangeBy = "Terraform"
    Project = "vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_forELB" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forELB" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports any traffic originating from the security group
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forELB" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

######### Bastion Host Security Group #########

resource "aws_security_group" "vprofile-bastion-sg" {
  name        = "vprofile-bastion-sg"
  description = "security group for vprofile-bastion"
  vpc_id      = module.vpc.vpc_id # reference to the VPC module

  tags = {
    Name    = "vprofile-bastion"
    MangeBy = "Terraform"
    Project = "vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sshfromyIPforBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

######### Beanstalk Environment Security Group #########

resource "aws_security_group" "vprofile-bean-sg" {
  name        = "vprofile-bean-sg"
  description = "security group for vprofile-bean"
  vpc_id      = module.vpc.vpc_id # reference to the VPC module

  tags = {
    Name    = "vprofile-bean-sg"
    MangeBy = "Terraform"
    Project = "vprofile"
  }
}

####### Ingress rule to allow traffic from the ELB security group
resource "aws_vpc_security_group_ingress_rule" "allow_http_fromELB" {
  security_group_id            = aws_security_group.vprofile-bean-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

####### Ingress rule to allow traffic from the ssh anywhere
resource "aws_vpc_security_group_ingress_rule" "sshfromanywhere" {
  security_group_id = aws_security_group.vprofile-bean-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forBeanInstance" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBeanInstance" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



####### backend security group egress rule to allow all traffic

resource "aws_security_group" "vprofile-backend-sg" {
  name        = "vprofile-backend-sg"
  description = "security group for RDS, Active mq , elastc cache"
  vpc_id      = module.vpc.vpc_id # reference to the VPC module

  tags = {
    Name    = "vprofile-backedn-sg"
    MangeBy = "Terraform"
    Project = "vprofile"
  }
}
####### Ingress rule to allow traffic from the Beanstalk security group

resource "aws_vpc_security_group_ingress_rule" "AllowfromBeanInstance" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bean-sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

####### Ingress rule to allow traffic from the Bastion security group

resource "aws_vpc_security_group_ingress_rule" "Allow3306FromBastioninstance" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bastion-sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forbackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBeanbackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "Backendsec_group_allow_itself" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-backend-sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}
