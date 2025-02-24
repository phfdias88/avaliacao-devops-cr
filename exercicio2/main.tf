# Exercicio 2

#Cria um Load Balance que distribui tráfego entre duas instâncias EC2, utilizando Auto Scaling.

# Configuração do provedor AWS
provider "aws" {
  region = "sa-east-1"
}

# Buscar a VPC
data "aws_vpc" "default" {
  id = "vpc-0219c2717996013bb"  # VPC ID fornecido
}

# Buscar as subnets públicas filtradas por zona de disponibilidade
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0219c2717996013bb"]  # Asegura que estamos pegando subnets dessa VPC específica
  }

  filter {
    name   = "mapPublicIpOnLaunch"
    values = ["true"]  # Seleciona as subnets públicas
  }
}

# Buscar automaticamente a AMI mais recente da Amazon Linux 2 (x86_64)
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # AMIs oficiais da AWS

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Mantendo compatível com t2.micro
  }
}

# Buscar o Security Group existente
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["web-security-group"]
  }
}

# Criar um Launch Template para as instâncias EC2
resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template"
  image_id      = data.aws_ami.latest_amazon_linux.id # Utiliza a AMI mais recente
  instance_type = "t2.micro"
  key_name      = "chave"  # Chave SSH correta
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "Servidor Web rodando em $(hostname)" > /var/www/html/index.html
              EOF
  )
}

# Auto Scaling Group para criar e manter 2 instâncias EC2
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [
    "subnet-0e0dc95d227f01725",  # Subnet em sa-east-1c
    "subnet-00004d67076245fa4",  # Subnet em sa-east-1a
    "subnet-0adda6d7e77791e38"   # Subnet em sa-east-1b
  ]
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}


# Application Load Balancer (ALB)
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.existing_sg.id]
  subnets            = [for s in data.aws_subnets.public_subnets.ids : s]  # Pegando os IDs das subnets públicas
}

# Criar Target Group para o ALB rotear tráfego
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# Listener do Load Balancer para direcionar o tráfego HTTP para as instâncias
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Associar Auto Scaling Group ao Target Group do ALB
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
  lb_target_group_arn   = aws_lb_target_group.web_tg.arn
}
