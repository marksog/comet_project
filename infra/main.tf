provider "aws" {
  region = var.region 
}

locals {
    name = var.project_name
    tags = {
      Project = var.project_name
    }
}

# ----- Networking -----

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.1"

    name = local.name
    cidr = var.vpc_cidr

    azs = ["${var.region}a", "${var.region}b"]
    private_subnets = var.private_subnet_cidrs
    public_subnets  = var.public_subnet_cidrs

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = "1"
    }
    tags = {
        Name = local.name
        Terraform = "true"
        Project = var.project_name
    }
}

# ----- EKS -----
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    cluster_name    = var.cluster_name
    cluster_version = var.eks_version
    subnet_ids      = module.vpc.private_subnets
    vpc_id          = module.vpc.vpc_id
    
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true   # just for testing purpose

    # access for iam users
    access_entries = {
        for user in var.admin_users : user => {
            principal_arn = user
            policy_associations = {
            adminss = {
                policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                access_scope = {
                type = "cluster"
                }
            }
          }
        }
    }

    eks_managed_node_groups = {
        default = {
            instance_types = var.node_instance_type
            min_size       = 2
            max_size       = 3
            desired_size   = 2
            iam_role_additional_policies = {
        ecr_read = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
  
  cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
        aws-ebs-csi-driver = {
            most_recent = true
            service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
        }
    }
  tags = local.tags
}  

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44"

  role_name             = "${var.cluster_name}-ebs-csi-controller"
  attach_ebs_csi_policy = true

  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# ----- ECR -----

resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
        Name = local.name
        Terraform = "true"
        Project = var.project_name
    }
}