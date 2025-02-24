# Exercicio 1

#Cria uma instância EC2 com um banco de dados RDS (MySQL) e um bucket S3.

# Configuração do provedor AWS
provider "aws" {
  region = "sa-east-1"
}


data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# Criação de uma instância EC2
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id  
  instance_type = "t2.micro"
  key_name      = "EC2KEY"  
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "ServidorWeb"
  }
}
# Criação de um grupo de segurança 
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Permitir SSH e MySQL"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criação de uma instância de banco de dados RDS (MySQL)
resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  identifier          = "meu-banco"
  username            = "admin"
  password            = "senhaSegura123"
  publicly_accessible = false
  skip_final_snapshot = true
}
# Criação de um bucket S3
resource "aws_s3_bucket" "bucket" {
  bucket = "meu-bucket-terraform-ph-123456789"
}


