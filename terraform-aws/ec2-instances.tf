module "web_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  for_each = var.instances

  name                   = each.key
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.app_mid_sg.id]

  subnet_id = element(module.vpc.private_subnets, index(keys(var.instances), each.key))

  user_data = each.value.user_data

#  depends_on = [aws_security_group.app-mid-sg]
 depends_on = [aws_security_group.app_mid_sg]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = each.key
  }
}
