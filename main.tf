resource "aws_instance" "instance" {
  depends_on                  = [aws_s3_bucket_object.object]
  ami                         = var.ami_id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name   = "${var.id}_server"
    Source = var.archive.output_md5
  }

  iam_instance_profile = aws_iam_instance_profile.profile.name

  user_data = <<EOF
#!/bin/bash
echo ${var.archive.output_md5}

sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.list | sudo tee /etc/apt/sources.list.d/tailscale.list

printf '${templatefile("${path.module}/basefiles/cloudwatch.json.tpl", {
  id  = var.id
})}' > /etc/cloudwatch.json
apt-get update -y && apt-get install -y tailscale collectd unzip
aws s3 cp s3://franscape-data-archive/source.zip /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/source.zip
unzip /home/ubuntu/source.zip -d /home/ubuntu/server
chown ubuntu:ubuntu -R /home/ubuntu/server
chmos +x /home/ubuntu/server/install.sh

su ubuntu -c "~/server/install.sh"
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "api" {
  name            = "${var.id}-lb"
  internal        = false
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.lb_secgroup.id]

  tags = {
    Name   = "${var.id}_alb"
    Project = var.id
  }
}

module "cert" {
  count   = var.cert_arn != "" ? 0 : 1
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "${var.subdomain != "" ? ".${var.subdomain}.${var.domain}" : var.domain}"
  zone_id     = var.zone_id

  tags = {
    Name   = "${var.id}_cert"
    Project = var.id
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn != "" ? var.cert_arn : module.cert[0].this_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  tags = {
    Name   = "${var.id}_lb_listener"
    Project = var.id
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.id}-api"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = {
    Name   = "${var.id}_target_group"
    Project = var.id
  }
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.instance.id
  port             = 1337

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "api" {
  name            = "${var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain}"
  type            = "CNAME"
  zone_id         = var.zone_id
  ttl             = 60
  records         = [aws_lb.api.dns_name]
  allow_overwrite = true
}