variable "region" {
  default = "ap-northeast-1"
}

variable "cluster-name" {
  default = "ld"
  type    = "string"
}

variable "instance_type" {
  default = "t3.xlarge"
}

variable "node_name" {
  default = "ld-eks-worker-poc"
}

variable "gossip_key" {}

variable "ca_path" {}
variable "consul_key_path" {}
variable "consul_cert_path" {}
variable "vault_key_path" {}
variable "vault_cert_path" {}
variable "account_id" {}
