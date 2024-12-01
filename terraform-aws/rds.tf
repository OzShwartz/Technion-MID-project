resource "aws_db_subnet_group" "main" {
  name       = "${var.vpc_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.vpc_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier              = "${var.vpc_name}-rds-instance"
  instance_class          = var.rds_instance_class
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  allocated_storage       = var.rds_storage
  db_name                 = var.rds_db_name
  username                = var.rds_master_username
  password                = var.rds_master_password
  backup_retention_period = var.rds_backup_retention
  multi_az                = var.rds_multi_az
  skip_final_snapshot     = var.rds_skip_final_snapshot
  vpc_security_group_ids  = [aws_security_group.instance_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.vpc_name}-rds-instance"
  }

  # Optional settings for performance and monitoring
  performance_insights_enabled = true
  performance_insights_kms_key_id = var.kms_key_id

  # Optional parameter for enabling encryption
  storage_encrypted = true
}
