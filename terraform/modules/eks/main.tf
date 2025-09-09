module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.7"

  cluster_name    = var.name
  cluster_version = "1.29"
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  enable_irsa = true

  eks_managed_node_group_defaults = {
    instance_types = [var.node_instance_type]
    ami_type       = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    default = {
      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.min_nodes

      # Grant autoscaling permissions to node role for demo simplicity
      iam_role_additional_policies = {
        autoscaling = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
      }
    }
  }
}

output "cluster_name"    { value = module.eks.cluster_name }
output "cluster_endpoint"{ value = module.eks.cluster_endpoint }
output "cluster_ca"      { value = module.eks.cluster_certificate_authority_data }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
