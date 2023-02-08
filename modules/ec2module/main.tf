data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

}

resource "aws_instance" "ec2-endy" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instancetype
  key_name        = "Endy-ensup"
  tags            = var.aws_common_tag
  security_groups = ["${aws_security_group.allow_ssh_http_https.name}"]

  provisioner "remote-exec" {
     inline = [
        "sudo apt-get update -y",
        "sudo apt-get install -y nginx git",
        "sudo rm -rf /var/www/html/*",
        "sudo chown -R ubuntu:www-data /var/www/html",
        "cd /var/www/html && git clone https://github.com/diranetafen/static-website-example.git .",
        "sudo chown -R www-data:www-data /var/www/html",
        "sudo systemctl start nginx",
     ]

   connection {
     type = "ssh"
     user = "ubuntu"
     private_key = file("/home/fujyn/Endy-ensup.pem")
     host = self.public_ip
   }
   }
  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = var.sg_name
  description = "Allow http and https inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_group_membership" "team" {
  name = "endy-membership"

  users = var.tf_users

  group = aws_iam_group.group.name
}

resource "aws_iam_group" "group" {
  name = "endy-group"
}

resource "aws_iam_user" "users" {
    for_each = var.tf_users
    name = each.key
}

resource "aws_iam_user_policy_attachment" "attach-user" {
  for_each = aws_iam_group_membership.team.users
  user       = each.value
  policy_arn = var.policy_arns
}


resource "aws_eip" "lb" {
  instance = aws_instance.ec2-endy.id
  vpc      = true
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${aws_eip.lb.public_ip} - ID: ${aws_instance.ec2-endy.id} - AZ: ${aws_instance.ec2-endy.availability_zone} >> infos_ec2.txt"
  }
}
