output "eks_primary_name" { value = module.eks_pri.cluster_name }
output "eks_secondary_name" { value = module.eks_sec.cluster_name }

output "ga_dns" {
  value = aws_globalaccelerator_accelerator.this.dns_name
}
