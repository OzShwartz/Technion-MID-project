module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc0mid-project"
  cidr = "10.1.0.0/16"  # Update to match the VPC CIDR block

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]  # Updated private subnets
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]  # Updated public subnets
  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}