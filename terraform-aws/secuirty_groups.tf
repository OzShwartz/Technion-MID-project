
resource "aws_security_group" "app_mid_sg" {
  name        = "app-mid-project_sg"
  description = "Security group for application instances"
  vpc_id = module.vpc.vpc_id


  # Flask App (Port 5000) - Restricted to specific IPs
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to Flask app from specified IP and within VPC"
  }

  # Prom (Port 9080) - Restricted to specific IP
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to Prom from specified IP and within VPC"
  }

  # Prometheus (Port 9090) - Restricted to specific IP
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to Prometheus from specified IP and within VPC"
  }

  # Grafana (Port 3000) - Restricted to specific IP
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to Grafana from specified IP and within VPC"
  }

  # Loki (Port 3100) - Restricted to specific IP
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to Loki from specified IP and within VPC"
  }

  # RDS MySQL (Port 3306) - Restricted to specific IP and VPC subnets
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "10.1.0.0/16"]
    description = "Allow traffic to RDS MySQL from specified IP and within VPC"
  }

  # ALB (Port 80) - Open to all
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic to ALB"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  depends_on = [module.vpc]

  tags = {
    Name = "app-mid-project_sg"
  }
}