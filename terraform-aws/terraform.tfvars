##VPC##
vpc_name            = "mid-project-vpc"
vpc_cidr            = "10.1.0.0/16"
private_subnets     = [
  "10.1.6.0/24", "10.1.7.0/24", "10.1.8.0/24", "10.1.9.0/24"
]
public_subnets      = [
  "10.1.1.0/24", "10.1.2.0/24"
]
enable_nat_gateway  = true
create_igw          = true

##EC2##
instances = {
  "ec2-webapp-az1" = { user_data = "webapp_az1_userdata.sh" },
  "ec2-webapp-az2" = { user_data = "webapp_az2_userdata.sh" },
  "ec2-monitoring" = { user_data = "monitoring_userdata.sh" },
  "ec2-database"   = { user_data = "database_userdata.sh" },
}

##S3##
s3_bucket_name = "backend-project-oz-s3-bucket"

##RDS##
rds_instance_class      = "db.t3.medium"
rds_engine              = "mysql"
rds_engine_version      = "8.0"
rds_storage             = 50
rds_db_name             = "mid-project-rds"
rds_master_username     = "admin"
rds_master_password     = "yourpassword"
rds_backup_retention    = 7
rds_multi_az            = true
rds_skip_final_snapshot = true
