module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.id}-strapi"
  cidr = "10.0.0.0/16"

  azs            = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Name = "${var.id} Strapi VPC"
    Client = var.id
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.id}_strapi_server"
  description = "${var.id} Strapi Sec Group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_ip}/32"]
  }

  ingress {
    description = "Strapi Input"
    from_port   = 1337
    to_port     = 1337
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
    Name = "${var.id}_strapi"
    Client = var.id
  }
}

resource "aws_security_group" "lb_secgroup" {
  name        = "${var.id}_strapi_lb"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.id}_strapi_lb"
    Client = var.id
  }
}