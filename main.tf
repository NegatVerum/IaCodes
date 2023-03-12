variable "dk_user" {}
variable "dk_password" {}
variable "create_instance" {
  type = bool
  default = true
}


provider "aws" {
  region = "us-west-1"
}

# Create a new security group
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to any IP address on any port
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance with the new security group
resource "aws_instance" "futbol2" {
  count = var.create_instance ? 1 : 0
  
  ami           = "ami-0036b4598ccd42565"
  instance_type = "t2.micro"
  key_name      = "my-key-pair"
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              EOF

/*  provisioner "remote-exec" {
    inline = [
     "sudo docker login -u ${var.dk_user} -p ${var.dk_password}",
     "sudo docker pull negatverum/futbol:latest",
     "sudo docker run -p 80:80 -d negatverum/futbol:latest",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./my-key-pair.pem")
    host        = self.public_ip
  }*/

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = true
  }

  tags = {
    Name = "futbol2"
  }

  vpc_security_group_ids = [
    aws_security_group.instance_sg.id
  ]
}
