resource "aws_security_group" "ec2" {
  name        = "ec2_sg"
  description = "Allow outbound SSH to 10.1.1.0/24"
  vpc_id      = "vpc-0f07bb72a3007caf1"

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.1.0/24"]
  }
}

resource "aws_instance" "ohio1" {
  ami                    = "ami-0d1b5a8c13042c939"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0adacf9c348a76e6c"
  vpc_security_group_ids = [aws_security_group.ec2.id]
}
