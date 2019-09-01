data "aws_availability_zones" "available" {}

data "aws_vpc" "demo" {
  id = "${var.vpc_id}"
}

data "aws_subnet" "demo" {
  id = "${var.subnet_id}"
}

data "aws_subnet" "demo2" {
  id = "${var.subnet_id2}"
}
