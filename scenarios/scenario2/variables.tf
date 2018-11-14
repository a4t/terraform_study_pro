variable "aws_role_arn" {}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "app_name" {
  default = "terraform-study"
}

variable "my_ip_list" {
  default = [
    "192.168.1.1/32",
    "192.168.1.2/32",
    "192.168.1.3/32",
  ]
}

variable "ports" {
  default = {
    ssh       = 22
    http      = 80
    https     = 443
    mysql     = 3306
    redis     = 6379
    memcached = 11211
  }
}
