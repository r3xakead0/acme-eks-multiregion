variable "name"               { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "node_instance_type" { type = string }
variable "min_nodes"          { type = number }
variable "max_nodes"          { type = number }
variable "region"             { type = string }
