provider "aws" {
  shared_credentials_file = "..\\..\\credentials"
  region = "${var.region}"
}

resource "aws_security_group" "home" {
  name = "home"
  description = "allow inbound traffic from home"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.home_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "controller" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.home.id}"]
  key_name = "${var.ssh_key_name}"

  connection {
    private_key = "${file("..\\home.pem")}"
    user = "ec2-user"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo easy_install pip",
      "sudo pip install ansible -q"
    ]

  }
}

output "ssh_location" {
  value = "ec2-user@${aws_instance.controller.public_dns}"
}
