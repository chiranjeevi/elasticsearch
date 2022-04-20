

data "aws_ami" "ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

}

resource "aws_iam_role" "elasticsearch_ec2_role" {
  name = "${terraform.workspace}_elasticsearch_ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name    = "ES ec2 role"
    version = var.infra_version
  }
}

resource "aws_iam_instance_profile" "elasticsearch_ec2_profile" {
  name = "${terraform.workspace}_elasticsearch_ec2_profile"
  role = aws_iam_role.elasticsearch_ec2_role.name
}

resource "aws_iam_role_policy" "elasticsearch_ec2_policy" {
  name = "${terraform.workspace}_elasticsearch_ec2_policy"
  role = aws_iam_role.elasticsearch_ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "codedeploy:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "es:*"
    ],
      "Resource": [
        "*"
    ]
  }
  ]
}
EOF
}

data "template_file" "es_instance" {
   depends_on = [
    aws_elasticsearch_domain.es_cluster,
  ]
  template = file("es_userdata.sh")
  vars = {
    es_cluster = aws_elasticsearch_domain.es_cluster.domain_name
  }
}
/*
resource "aws_instance" "elasticsearch-instance" {
  
  ami           = data.aws_ami.ec2.id
  instance_type = "t2.small"
  key_name      = var.key_name

  vpc_security_group_ids      = ["${aws_security_group.sg_allow_ssh_elasticsearch.id}"]
  subnet_id                   = aws_subnet.pub-subnet-1.id
  iam_instance_profile        = aws_iam_instance_profile.elasticsearch_ec2_profile.name
  user_data                   = base64encode(data.template_file.es_instance.rendered)
  associate_public_ip_address = true
  tags = {
    Name    = "Elasticsearch ec2"
    version = var.infra_version
  }
}*/


resource "aws_security_group" "sg_allow_ssh_elasticsearch" {
  name        = "${terraform.workspace}_allow_ssh_elasticsearch"
  description = "Allow SSH and elasticsearch inbound traffic"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5600
    to_port     = 5600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "Devops 3TierApp"
    version = var.infra_version
  }
}

output "es_filebeat_ip_address" {
  value = aws_instance.elasticsearch-instance.public_ip
}


resource "aws_cloudwatch_log_group" "devops_log" {
  name              = "${terraform.workspace}-devops-log-group"
  retention_in_days = 7
  tags = {
    Name    = "Elasticsearch loggroup"
    version = var.infra_version
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


resource "aws_elasticsearch_domain" "es_cluster" {
  domain_name           = "${terraform.workspace}-${var.domain}"
  elasticsearch_version = "7.10"

  ebs_options{
        ebs_enabled = true
        volume_size = 10
    }
  cluster_config {
    instance_type = "t3.medium.elasticsearch"
  }
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*",
      "Condition": {
        "IpAddress": {"aws:SourceIp": ["${var.pub_subnet_cidr_1}"]}
      }
    }
  ]
}
POLICY
  tags = {
    Domain = "TestDomain"
  }
}