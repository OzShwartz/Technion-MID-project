
##########     ALB Security Group   ########

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP traffic to ALB and apps"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules for the applications
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic to ALB (port 80)
  }

  # Flask (Port 5001)
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to Flask app (port 5001)
  }

  # MySql (Port 3306)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to MySql (port 3306)
  }

  # Prom (Port 9080)
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to Prom (port 9080)
  }

  # Grafana (Port 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to Grafana (port 3000)
  }
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to Grafana (port 3000)
  }

  # Egress (outbound traffic, allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "alb_sg"
  }
}

##########       ALB Setup        ##########

# ALB Setup
resource "aws_lb" "app__lb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "alb-mid-project"
  }
}

##########   Target Groups and Health Checks  ##########   

# Flask App Target Group (Port 5001)
resource "aws_lb_target_group" "flask_tg" {
  name        = "flask-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"              # Define the health check path
    protocol            = "HTTP"
    port                = "5001"           # Health check on the same port as the application
    interval            = 30               # Interval between health checks (30 seconds)
    timeout             = 5                # Timeout for health check response (5 seconds)
    healthy_threshold   = 2                # Number of successes to mark as healthy
    unhealthy_threshold = 2                # Number of failures to mark as unhealthy
    matcher             = "200"            # HTTP 200 OK expected for a healthy response
  }

  tags = {
    Name = "flask-tg"
  }
}

# MySql Target Group (Port 3306)
resource "aws_lb_target_group" "mysql_tg" {
  name        = "mysql-tg"
  port        = 3306
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/status"              # Define the health check path
    protocol            = "HTTP"
    port                = "3306"           # Health check on the same port as MySql
    interval            = 30               # Interval between health checks (30 seconds)
    timeout             = 5                # Timeout for health check response (5 seconds)
    healthy_threshold   = 2                # Number of successes to mark as healthy
    unhealthy_threshold = 2                # Number of failures to mark as unhealthy
    matcher             = "200"            # HTTP 200 OK expected for a healthy response
  }

  tags = {
    Name = "mysql-tg"
  }
}

# Prom Target Group (Port 9080)
resource "aws_lb_target_group" "prom_tg" {
  name        = "prom-tg"
  port        = 9080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/metrics"       # Health check endpoint for Prom
    protocol            = "HTTP"
    port                = "9080"           # Health check on the same port as Prom
    interval            = 30               # Interval between health checks (30 seconds)
    timeout             = 5                # Timeout for health check response (5 seconds)
    healthy_threshold   = 2                # Number of successes to mark as healthy
    unhealthy_threshold = 2                # Number of failures to mark as unhealthy
    matcher             = "200"            # HTTP 200 OK expected for a healthy response
  }

  tags = {
    Name = "prom-tg"
  }
}

# Grafana Target Group (Port 3000)
resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"              # Health check endpoint for Grafana
    protocol            = "HTTP"
    port                = "3000"           # Health check on the same port as Grafana
    interval            = 30               # Interval between health checks (30 seconds)
    timeout             = 5                # Timeout for health check response (5 seconds)
    healthy_threshold   = 2                # Number of successes to mark as healthy
    unhealthy_threshold = 2                # Number of failures to mark as unhealthy
    matcher             = "200"            # HTTP 200 OK expected for a healthy response
  }

  tags = {
    Name = "grafana-tg"
  }
}

# Loki Target Group (Port 3100)
resource "aws_lb_target_group" "loki_tg" {
  name        = "loki-tg"
  port        = 3100
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/loki/api/v1/status/ready"  # Change this based on Loki's readiness endpoint
    protocol            = "HTTP"
    port                = "3100"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "loki-tg"
  }
}


##########     ALB Listeners      ########## 


# ALB Listener for HTTP traffic on port 80
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn  # Default route to Flask app
  }
}

##########    ALB Listener Rules   #########

# Listener for Flask App (Port 5001)
resource "aws_lb_listener" "flask_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 5001
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}

# Listener for MySql (Port 3306)
resource "aws_lb_listener" "mysql_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 3306
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mysql_tg.arn  # Correct reference to target group ARN
  }
}


# Listener for Prom (Port 9080)
resource "aws_lb_listener" "prom_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 9080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prom_tg.arn
  }
}

# Listener for Grafana (Port 3000)
resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}


# Listener for Loki (Port 3100)
resource "aws_lb_listener" "loki_listener" {
  load_balancer_arn = aws_lb.app__lb.arn
  port              = 3100
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loki_tg.arn
  }
}

##########  Target Group Attachments #########


# Attach Flask instances to Flask target group
resource "aws_lb_target_group_attachment" "flask_attachment_1" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = module.web_instance["ec2-webapp-az1"].id
  port             = 5001  # Flask runs on port 5001
}

resource "aws_lb_target_group_attachment" "flask_attachment_2" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = module.web_instance["ec2-webapp-az2"].id
  port             = 5001  # Flask runs on port 5001
}

# Attach Grafana instance to Grafana target group
resource "aws_lb_target_group_attachment" "grafana_attachment" {
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = module.web_instance["ec2-monitoring"].id
  port             = 3000  # Grafana runs on port 3000
}

# Attach MySql instance to MySql target group
resource "aws_lb_target_group_attachment" "mysql_attachment" {
  target_group_arn = aws_lb_target_group.mysql_tg.arn
  target_id        = module.web_instance["ec2-database"].id  # The instance where MySql is running
  port             = 3306  # MySql runs on port 3306
}


# Attach Prom instance to Prom target group
resource "aws_lb_target_group_attachment" "prom_attachment" {
  target_group_arn = aws_lb_target_group.prom_tg.arn
  target_id        = module.web_instance["ec2-monitoring"].id  # Adjust this to the instance where Prom is running
  port             = 9080  # Prom runs on port 9080
}

# Attach Loki instance to Loki target group
resource "aws_lb_target_group_attachment" "loki_attachment" {
  target_group_arn = aws_lb_target_group.loki_tg.arn
  target_id        = module.web_instance["ec2-monitoring"].id  # Adjust this to the instance where Loki is running
  port             = 3100  # Loki runs on port 3100
}