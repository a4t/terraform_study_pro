# Terraformの機能を知る

## 変数を使う

`variable` で定義して `${var.[変数名]}` という使い方をする

```
variable "aws_region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.aws_region}"
}
```

## countを使う

VPC `vpc-123456789` に以下のsubnetが作成される

for文をイメージするとわかりやすい

- 10.0.0.0/24
- 10.0.1.0/24

```
resource "aws_subnet" "subnet" {
  count      = 2
  vpc_id     = "vpc-123456789"
  cidr_block = "10.0.${count.index}.0/24"
}
```

## listを使う

Security Group `ssh_allow` が作成される

以下のケースの場合、Port 22にアクセスできるCIDRが3つ生成される

```
variable "my_ip_list" {
  default = [
    "192.168.1.1/32",
    "192.168.1.2/32",
    "192.168.1.3/32",
  ]
}

resource "aws_security_group" "ssh_allow" {
  name   = "ssh_allow"
  vpc_id = "vpc-123456789"

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.my_ip_list}"
  }
}
```

## mapを使う

以下のケースの場合 `Port 22` のegressが開放される

```
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

resource "aws_security_group" "ssh_allow" {
  name   = "ssh_allow"
  vpc_id = "vpc-123456789"

  egress {
    from_port   = "${var.ports["ssh"]}"
    to_port     = "${var.ports["ssh"]}"
    protocol    = "tcp"
    cidr_blocks = "192.168.1.1/32"
  }
}
```

## リソース同士を連携する

以下の場合VPCを作成し、そのVPCに紐付いたsubnetが作成される

```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
}
```

## tfstateをS3で共有する

以下の場合、S3の `mybucket` の `path/to/my/terraform.tfstate` にtfstateが保管される

他の開発者と共通で使うことになるので、お互いの作業によってtfstateの状態がズレることを防ぐことができる

```
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

## Demo

上記の機能を使ったtfファイルが用意されているので `terraform plan` を実行してみると動きがわかる

Backendの設定だけ各自のAWSの認証情報やBucket情報が必要なので、以下のようなコマンドを入力すること

```bash
$ terraform init \
    -backend-config="profile=my-profile" \
    -backend-config="bucket=terraform-study-sample-bucket" \
    -backend-config="region=ap-northeast-1"
```
