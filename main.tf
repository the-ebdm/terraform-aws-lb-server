resource "aws_instance" "instance" {
  depends_on                  = [aws_s3_bucket_object.object]
  ami                         = var.ami_id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name   = "${var.id} server"
    Source = var.archive.output_md5
  }

  iam_instance_profile = aws_iam_role_policy.policy.name

  user_data = <<EOF
#!/bin/bash
echo ${var.archive.output_md5}
apt update -y && apt install -y unzip 
aws s3 cp s3://franscape-data-archive/source.zip /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/source.zip
unzip /home/ubuntu/source.zip -d /home/ubuntu/server
chown ubuntu:ubuntu -R /home/ubuntu/server

su ubuntu -c ""
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "api" {
  name            = "${var.id}-strapi-lb"
  internal        = false
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.lb_secgroup.id]

  tags = {
    Name   = "strapi_api_alb"
    Client = var.id
  }
}

module "cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "${var.subdomain != "" ? ".${var.subdomain}" : null}.${var.domain}"
  zone_id     = var.zone_id
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.cert.this_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.id}-strapi-api"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.instance.id
  port             = 1337

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "server" {
  name            = "server${var.subdomain != "" ? ".${var.subdomain}" : null}.${var.domain}"
  type            = "A"
  zone_id         = var.zone_id
  ttl             = 60
  records         = [aws_instance.instance.public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "api" {
  name            = "${var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain} "
  type            = "CNAME"
  zone_id         = var.zone_id
  ttl             = 60
  records         = [aws_lb.api.dns_name]
  allow_overwrite = true
}