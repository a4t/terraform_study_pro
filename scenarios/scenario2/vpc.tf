resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "${var.app_name}"
  }
}

resource "aws_subnet" "main" {
  count      = 3
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.${count.index}.0/24"

  tags {
    Name = "${var.app_name}-subnet-${count.index}"
  }
}
