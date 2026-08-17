terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 조회: 최신 Amazon Linux 2023 이미지 (resource가 아니라 data!)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro" # 프리티어 대상
}

# 방화벽: 80번 포트(HTTP)만 개방
resource "aws_security_group" "web" {
  name        = "study-web-sg"
  description = "Allow HTTP inbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접속 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 나가는 건 전부 허용
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 드디어 서버!
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id # data 참조
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id] # resource 참조

  # 부팅 시 자동 실행되는 스크립트: 웹서버 설치
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
    systemctl enable --now httpd
  EOF

  tags = {
    Name = "terraform-study-web"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}