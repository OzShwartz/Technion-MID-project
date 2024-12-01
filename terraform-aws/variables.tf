variable "AWS_REGION" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

##VPC##
variable "vpc_name" {
  description = "The AWS vpc name"
  type        = string
  default     = "sample"
}

variable "vpc_cidr" {
  description = "The AWS vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable the NAT gateway"
  type        = bool
}

##S3##
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

##EC2##
variable "instances" {
  description = "Map of instances with user_data and configuration"
  type = map(object({
    user_data = string
  }))
  default = {
    "ec2-webapp-az1" = { user_data = "webapp_az1_userdata.sh" },
    "ec2-webapp-az2" = { user_data = "webapp_az2_userdata.sh" },
    "ec2-monitoring" = { user_data = "monitoring_userdata.sh" },
    "ec2-database"   = { user_data = "database_userdata.sh" },
  }
}

##RDS##
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_engine" {
  description = "RDS engine"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The version of the engine to use"
  type        = string
  default     = "8.0"
}
