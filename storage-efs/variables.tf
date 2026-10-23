variable "name" { type=string }
variable "vpc_id" { type=string }
variable "subnet_ids" { type=list(string) }
variable "ingress_cidr_blocks" { type=list(string) default=["10.0.0.0/16"] }
variable "encrypted" { type=bool default=true }
variable "tags" { type=map(string) default={} }
