module "tags" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git"
  namespace   = var.name
  environment = var.env
  name        = format("%s.%s", var.name, var.env)
  delimiter   = "_"

  tags = {
    owner     = var.owner
    project   = var.project
    env       = var.env
    workspace = var.workspace
    comments  = "agents"
  }
}

resource "tls_private_key" "agents" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "agents" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.agents.private_key_pem
  validity_period_hours = 24

  subject {
    common_name  = "api.k3s.lab"
    organization = "Chaos Engineers (Kenya)"
  }


  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "aws_acm_certificate" "agents" {
  private_key      = tls_private_key.agents.private_key_pem
  certificate_body = tls_self_signed_cert.agents.cert_pem
}

resource "aws_subnet" "agents" {
  vpc_id                  = var.vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az[0]
  tags                    = module.tags.tags
}

resource "aws_security_group_rule" "from_cp" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = var.control_plane_sg_id
  security_group_id        = aws_security_group.agents.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 30000
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.agents.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 30001
  to_port           = 30001
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.agents.id
}

resource "aws_security_group_rule" "internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.agents.id
}

resource "aws_security_group" "agents" {
  vpc_id = var.vpc.id
  tags   = module.tags.tags
}

resource "aws_key_pair" "agents" {
  key_name   = format("%s%s", var.name, "_keypair_agents")
  public_key = file(var.public_key_path)
}

data "aws_ami" "latest_agents" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^${var.name}-k3s-agent-\\d*$"

  filter {
    name   = "name"
    values = ["${var.name}-k3s-agent-*"]
  }
}

resource "aws_launch_configuration" "agents" {
  name            = "agents"
  image_id        = data.aws_ami.latest_agents.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.agents.id]
  key_name        = aws_key_pair.agents.id
}

resource "aws_route53_record" "agents" {
  zone_id = var.zone.zone_id
  type    = "A"
  name    = format("%s.%s", "api", var.zone.name)
  ttl     = "300"
  records = [aws_eip.agents.public_ip]
}

resource "aws_eip" "agents" {
  vpc = true
}

resource "aws_lb" "agents" {
  name               = "basic-load-balancer"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.agents.id
    allocation_id = aws_eip.agents.id
  }
}

resource "aws_lb_listener" "agents_80" {
  load_balancer_arn = aws_lb.agents.arn

  protocol = "TCP"
  port     = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.agents_80.arn
  }
}
resource "aws_lb_listener" "agents_443" {
  load_balancer_arn = aws_lb.agents.arn

  protocol = "TLS"
  port     = 443

  certificate_arn = aws_acm_certificate.agents.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.agents_443.arn
  }
}

resource "aws_lb_target_group" "agents_80" {
  port     = 30000
  protocol = "TCP"
  vpc_id   = var.vpc.id

  stickiness {
    type    = "source_ip"
    enabled = false
  }

  health_check {
    path                = "/healthz"
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
  }

  depends_on = [
    aws_lb.agents
  ]

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group" "agents_443" {
  port     = 30001
  protocol = "TCP"
  vpc_id   = var.vpc.id

  stickiness {
    type    = "source_ip"
    enabled = false
  }

  health_check {
    path                = "/healthz"
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
  }

  depends_on = [
    aws_lb.agents
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "agents_80" {
  autoscaling_group_name = aws_autoscaling_group.agents.name
  alb_target_group_arn   = aws_lb_target_group.agents_80.arn
}

resource "aws_autoscaling_attachment" "agents_443" {
  autoscaling_group_name = aws_autoscaling_group.agents.name
  alb_target_group_arn   = aws_lb_target_group.agents_443.arn
}

resource "aws_autoscaling_group" "agents" {
  name                      = "agents"
  max_size                  = 5
  min_size                  = 3
  desired_capacity          = 3
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.agents.id]
  launch_configuration      = aws_launch_configuration.agents.name

  lifecycle {
    ignore_changes        = [load_balancers, target_group_arns]
    create_before_destroy = true
  }

  tag {
    key                 = "owner"
    value               = var.owner
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "workspace"
    value               = var.workspace
    propagate_at_launch = true
  }

  tag {
    key                 = "comments"
    value               = "agent"
    propagate_at_launch = true
  }

}
