
variable "AWS_DEFAULT_REGION" {
  default = "us-east-1"
}
variable "AWS_ACCESS_KEY_ID" {
  type = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}
variable "vpc_subnet_cidr" {
  default = "10.0.0.0/16"
}
variable "pub_subnet_cidr_1" {
  default = "10.0.1.0/24"
}
variable "pub_subnet_cidr_2" {
  default = "10.0.2.0/24"
}
variable "private_subnet_cidr_1" {
  default = "10.0.21.0/24"
}
variable "private_subnet_cidr_2" {
  default = "10.0.22.0/24"
}
variable "region" {
  default = "us-east-1"

}
variable "key_name" {
  default = "chiran"
}
variable "infra_version" {
  default = "1.0.0"
}
variable "domain" {
  default = "test"
}