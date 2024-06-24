module "vpc" {
  create_vpc = true
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name    = "${var.name}-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["${var.region}a", "${var.region}b"]
  private_subnets = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
  public_subnets = [
    "10.0.11.0/24", "10.0.12.0/24"
  ]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
     "kubernetes.io/role/elb"              = 1
  }
   private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
    "karpenter.sh/discovery" = "${var.name}"
  }
}
