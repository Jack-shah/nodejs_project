data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240611.0-kernel-6.1-x86_64"]
  }
}

module "bastion" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  create = true
  version                     = "5.6.1"
  name                        = "${var.name}-bastion"
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.amazon_linux.id
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  subnet_id                   = element(module.vpc.private_subnets, 0)
  associate_public_ip_address = false
  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CustomIAMPolicy = aws_iam_policy.bastion.arn
  }

  user_data = <<-EOT
    #!/bin/bash
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/${module.eks.cluster_version}.0/2024-05-12/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/bin/
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
    echo "alias k=kubectl" >> /etc/profile
  EOT
}

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  create = true

  name         = "${var.name}-bastion"
  vpc_id       = module.vpc.vpc_id
  egress_rules = ["all-all"]
}

output "bastion_instance_id" {
  value = module.bastion.id
}