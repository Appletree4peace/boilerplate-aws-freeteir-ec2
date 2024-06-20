resource "aws_key_pair" "deployer" {
  key_name   = "vultr"
  public_key = file("files/id_rsa.vultr.pub")
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "SSMRoleForInstancesProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "ec2" {
  ami                         = local.config.ami
  instance_type               = local.config.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  subnet_id                   = local.config.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = local.config.tags

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    echo "${file("files/id_rsa.vultr.pub")}" >> /home/ec2-user/.ssh/authorized_keys
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
    chmod 700 /home/ec2-user/.ssh
    chmod 600 /home/ec2-user/.ssh/authorized_keys
  EOF

  provisioner "local-exec" {
    command    = "cd ../.. && make _bootstrap"
    on_failure = continue
  }
}

# Create a security group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH and ICMP from VPC"
  vpc_id      = local.config.vpc_id

  dynamic "ingress" {
    for_each = local.config.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = local.config.extra_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  #  ingress {
  #    description = "SSH"
  #    from_port   = 22
  #    to_port     = 22
  #    protocol    = "tcp"
  #    cidr_blocks = ["${local.config.home_ip}/32"]
  #  }
  #
  #  ingress {
  #    description = "HTTP"
  #    from_port   = 80
  #    to_port     = 80
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #
  #  ingress {
  #    description = "HTTPS"
  #    from_port   = 443
  #    to_port     = 443
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #
  #  ingress {
  #    description = "ALL"
  #    from_port   = 0
  #    to_port     = 0
  #    protocol    = "tcp"
  #    cidr_blocks = [local.config.vpc_cidr]
  #  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_id" {
  value = aws_instance.ec2.id
}