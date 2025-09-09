locals {
  name_pri           = "${var.project}-${var.env}-pri"
  name_sec           = "${var.project}-${var.env}-sec"
  nlb_name_primary   = "${var.project}-${var.env}-nlb-pri"
  nlb_name_secondary = "${var.project}-${var.env}-nlb-sec"
}

/* NETWORK – Primary */
module "vpc_pri" {
  source             = "../../modules/network"
  name               = local.name_pri
  cidr               = "10.10.0.0/16"
  azs                = ["${var.region_primary}a", "${var.region_primary}b"]
  public_subnets     = ["10.10.0.0/20", "10.10.16.0/20"]
  private_subnets    = ["10.10.96.0/20", "10.10.112.0/20"]
  single_nat_gateway = var.nat_gateways_per_region == 1
}

/* NETWORK – Secondary */
module "vpc_sec" {
  source             = "../../modules/network"
  providers          = { aws = aws.secondary }
  name               = local.name_sec
  cidr               = "10.20.0.0/16"
  azs                = ["${var.region_secondary}a", "${var.region_secondary}b"]
  public_subnets     = ["10.20.0.0/20", "10.20.16.0/20"]
  private_subnets    = ["10.20.96.0/20", "10.20.112.0/20"]
  single_nat_gateway = var.nat_gateways_per_region == 1
}

/* (Optional) Peering – demo only */
resource "aws_vpc_peering_connection" "cr" {
  vpc_id      = module.vpc_pri.vpc_id
  peer_vpc_id = module.vpc_sec.vpc_id
  peer_region = var.region_secondary
  auto_accept = false
  tags = {
    Name = "${local.name_pri}-to-${local.name_sec}"
  }
}

/* EKS – Primary */
module "eks_pri" {
  source             = "../../modules/eks"
  name               = local.name_pri
  vpc_id             = module.vpc_pri.vpc_id
  private_subnet_ids = module.vpc_pri.private_subnets
  node_instance_type = var.node_instance_type
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  region             = var.region_primary
}

/* EKS – Secondary */
module "eks_sec" {
  source             = "../../modules/eks"
  providers          = { aws = aws.secondary }
  name               = local.name_sec
  vpc_id             = module.vpc_sec.vpc_id
  private_subnet_ids = module.vpc_sec.private_subnets
  node_instance_type = var.node_instance_type
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  region             = var.region_secondary
}

/* GLOBAL ACCELERATOR – attaches later to NLBs created by Services.
   We look up NLBs by fixed names set in k8s Service annotations. */
# resource "aws_globalaccelerator_accelerator" "this" {
#   name            = "${var.project}-${var.env}-ga"
#   enabled         = true
#   ip_address_type = "IPV4"
# }

# resource "aws_globalaccelerator_listener" "http" {
#   accelerator_arn = aws_globalaccelerator_accelerator.this.id
#   protocol        = "TCP"

#   port_range {
#     from_port = 80
#     to_port   = 80
#   }
# }

# Lookup NLBs by name in each region (they will exist after app deploy)
# data "aws_lb" "nlb_pri" {
#   name = local.nlb_name_primary
#   # default provider (primary region)
# }

# data "aws_lb" "nlb_sec" {
#   provider = aws.secondary
#   name     = local.nlb_name_secondary
# }

# resource "aws_globalaccelerator_endpoint_group" "pri" {
#   listener_arn          = aws_globalaccelerator_listener.http.id
#   endpoint_group_region = var.region_primary
#   health_check_protocol = "TCP"
#   health_check_port     = 80

#   endpoint_configuration {
#     endpoint_id = data.aws_lb.nlb_pri.arn
#     weight      = 100
#   }
# }

# resource "aws_globalaccelerator_endpoint_group" "sec" {
#   listener_arn          = aws_globalaccelerator_listener.http.id
#   endpoint_group_region = var.region_secondary
#   health_check_protocol = "TCP"
#   health_check_port     = 80

#   endpoint_configuration {
#     endpoint_id = data.aws_lb.nlb_sec.arn
#     weight      = 100
#   }
# }
