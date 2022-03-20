resource "aws_vpc" "devops_vpc" {
  cidr_block = var.vpc_subnet_cidr
  tags = {
    Name    = "Elasticsearch"
    version = var.infra_version
  }
}

resource "aws_subnet" "pub-subnet-1" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = var.pub_subnet_cidr_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "Elasticsearch pub subnet"
    version = var.infra_version
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name    = "Elasticsearch igw"
    version = var.infra_version
  }
}


resource "aws_route_table" "web-routing" {
  vpc_id = aws_vpc.devops_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "Elasticsearch routetable"
    version = var.infra_version
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-subnet-1.id
  route_table_id = aws_route_table.web-routing.id
}
