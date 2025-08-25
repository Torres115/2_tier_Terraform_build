resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "alb from mgmt"
  vpc_id      = "vpc-0f07bb72a3007caf1"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "asg" {
  name        = "app-asg-sg"
  description = "ssh and http rules"
  vpc_id      = "vpc-0f07bb72a3007caf1"

  ingress {
    description     = "ssh from ec2 sg"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  ingress {
    description     = "http from alb sg"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app" {
  name               = "app-int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = ["subnet-0f383dea9b8f627ca", "subnet-03ee384828c2a7886"]
}

resource "aws_lb_target_group" "app" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0f07bb72a3007caf1"

  health_check {
    path              = "/"
    matcher           = "200-399"
    interval          = 15
    healthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  name_prefix            = "app-lt-"
  image_id               = "ami-0d1b5a8c13042c939"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.asg.id]

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -eux
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y apache2
    systemctl enable apache2
    echo "Hello from $(hostname) at $(date)" > /var/www/html/index.html
    systemctl restart apache2
  EOT
  )
}

resource "aws_autoscaling_group" "app" {
  name                      = "app-asg"
  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  vpc_zone_identifier       = ["subnet-0f383dea9b8f627ca"]
  health_check_type         = "ELB"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}
