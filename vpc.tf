module "vpc" { # This is the VPC module that we are using to create the VPC and subnets in the AWS account
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_NAME
  cidr = var.VpcCIDR

  azs             = [var.Zone1, var.Zone2, var.Zone3]
  private_subnets = [var.PrivSub1CIDR, var.PrivSub2CIDR, var.PrivSub3CIDR]
  public_subnets  = [var.PubSub1CIDR, var.PubSub2CIDR, var.PubSub3CIDR]

  enable_nat_gateway      = true # This will create a NAT Gateway in each public subnet and it's expensive
  single_nat_gateway      = true # This will create a single NAT Gateway in the first public subnet
  enable_dns_hostnames    = true # This will enable DNS hostnames in the VPC
  enable_dns_support      = true # This will enable DNS support in the VPC
  map_public_ip_on_launch = true # This will assign a public IP to the instances launched in the public subnet

  tags = {
    Name    = var.VPC_NAME
    Project = var.PROJECT
  }
}