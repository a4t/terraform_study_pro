resource "aws_security_group" "allow_mysql_and_ssh" {
  name   = "${var.app_name}-allow-mysql-and-ssh"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "${var.ports["ssh"]}"
    to_port     = "${var.ports["ssh"]}"
    protocol    = "tcp"
    cidr_blocks = "${var.my_ip_list}"
  }

  egress {
    from_port   = "${var.ports["mysql"]}"
    to_port     = "${var.ports["mysql"]}"
    protocol    = "tcp"
    cidr_blocks = "${var.my_ip_list}"
  }
}
