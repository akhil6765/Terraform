

# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
    access_key = "***********"
    secret_key = "************************"
    
    }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#Configure EC2 instance
resource "aws_instance" "EC2_test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "ec2_new_key"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "Simplilearn EC2"
  }
}

  resource "null_resource" "copyhtml" {
  
    connection {
    type = "ssh"
    host = aws_instance.EC2_test.public_ip
    user = "ubuntu"
    private_key = file("ec2_new_key.pem")
    }
  provisioner "file" {
    source      = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }
  provisioner "file" {
    source      = "install_python.sh"
    destination = "/tmp/install_python.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/install_jenkins.sh",
      "sh /tmp/install_jenkins.sh",
      "sudo chmod 777 /tmp/install_python.sh",
      "sh /tmp/install_python.sh",
    ]
  }

  depends_on = [ aws_instance.EC2_test ]
  }
  
  
  

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}



