resource "aws_spot_instance_request" "cheap_worker" {
  count         = length(var.components)
  ami           = data.aws_ami.ami.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-06ec2f14a6137cc44"]
  wait_for_fulfillment = true
  tags = {
    Name = local.COMP_NAME
  }
}

resource "aws_ec2_tag" "tags" {
  count       = length(var.components)
  resource_id = element(aws_spot_instance_request.cheap_worker.*.spot_instance_id, count.index)
  key         = "Name"
  value       = local.COMP_NAME
}

resource "null_resource" "ansible" {
  count = length(var.components)
  provisioner "remote-exec" {
    connection {
      host     = element(aws_spot_instance_request.cheap_worker.*.private_ip, count.index)
      user     = "centos"
      password = "DevOps321"
    }
    inline = [
      "yum install python3-pip -y",
      "pip3 install pip --upgrade",
      "pip3 install ansible",
      "ansible-pull -U https://github.com/pradhan02/ansible.git -e COMPONENT=${local.COMP_NAME} -e ENV=dev"
    ]
  }
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "^Cent*"
  owners      = ["973714476881"]
}

variable "components" {
  default = ["frontend", "mongodb", "catalogue", "cart", "user", "redis", "mysql", "shipping", "rabbitmq", "payment"]
}

provider "aws" {
  region = "us-east-1"
}
locals{
  COMP_NAME = element(var.components, count.index)
}

