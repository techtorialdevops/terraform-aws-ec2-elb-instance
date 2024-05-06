provider "aws" {
  region = var.region
}

resource "aws_instance" "terraform6" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = var.key_name

  tags = {
    Name = "terraform6"
  }
}

# Create a new load balancer
resource "aws_elb" "terraform6" {
  name               = "tuncay-terraform6-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  access_logs {
    bucket        = "terraform6"
    bucket_prefix = "tuncay-"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.terraform6.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "tuncay-terraform6-elb"
  }
}

resource "aws_s3_bucket" "tuncay-terraform6" {
  bucket = "tuncay-terraform6"

  tags = {
    Name        = "tuncay-terraform6"
    Environment = "Dev"
  }
}
