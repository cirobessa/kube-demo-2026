
resource "aws_vpc" "this" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "eks-network-10.10" }
}
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "eks-public-${count.index}" }
}
data "aws_availability_zones" "available" { state = "available" }
