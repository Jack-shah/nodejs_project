data "aws_caller_identity" "current" {}
module "eks" {
  create = true
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.13.1"
  cluster_name                             = var.name
  cluster_version                          = "1.30"
  cluster_endpoint_public_access           = false
  cluster_endpoint_private_access = true
  create_iam_role = true
  authentication_mode = "API"
  cluster_security_group_additional_rules = {
    ingress_bastion = {
      protocol = "tcp"
      from_port = 443
      to_port = 443
      source_security_group_id = module.bastion_sg.security_group_id
      type = "ingress"
    }
  }
  enable_cluster_creator_admin_permissions = true
  cluster_addons = {
    coredns = {
      most_recent = true
      before_compute = false
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }
  access_entries = {
    admin = {
      kubernetes_group = []
      principal_arn = module.bastion.iam_role_arn
      username = "bastion"
      policy_associations = {
        single = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  enable_irsa = true
  eks_managed_node_groups = {
    "eks-node" = {
      ami_type = "AL2_x86_64"
      platform = "al2023"
      create_iam_role = true
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 3
      desired_size = 1

      update_config = {
        max_unavailable = 1
      }
      force_update_version = true
    }
    tags = {
      "karpenter.sh/discovery" = "${var.name}"
    }
  }
}

module "vpc_cni_irsa" {
  source  = "registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.1"

  role_name_prefix      = "${var.name}-vpc-cni-role"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
