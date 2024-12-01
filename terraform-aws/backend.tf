terraform {
  backend "s3" {
    bucket         = "backend-project-oz-s3-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  #  dynamodb_table = "terraform-lock-table"
  }
}
