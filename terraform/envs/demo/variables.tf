variable "project" {
  type    = string
  default = "acme"
}
variable "env" {
  type    = string
  default = "demo"
}
variable "region_primary" {
  type    = string
  default = "us-east-1"
}
variable "region_secondary" {
  type    = string
  default = "us-west-2"
}
variable "nat_gateways_per_region" {
  type    = number
  default = 1
}
variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}
variable "min_nodes" {
  type    = number
  default = 1
}
variable "max_nodes" {
  type    = number
  default = 3
}
