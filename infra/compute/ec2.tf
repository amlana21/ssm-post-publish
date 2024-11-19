
# key pair
resource "aws_key_pair" "app_cp_key" {
  key_name   = "cp-instance-key"
  public_key = "key_content"
}

resource "aws_network_interface" "app_instance_eni" {
  subnet_id       = var.subnet_ids[0]
  security_groups = [var.lb_sg_id]  
}


resource "aws_instance" "app_instance" {
  ami           = "ami-06b21ccaeff8cd686" # us-east-1
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = resource.aws_network_interface.app_instance_eni.id
    device_index         = 0
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  restart amazon-ssm-agent
  sudo yum install nginx -y
  sudo chkconfig nginx on
  sudo service nginx start
  # end
  EOF
  availability_zone = "us-east-1a"
  key_name = resource.aws_key_pair.app_cp_key.key_name

  tags= {
    Name = "TestConnect"
  }

  iam_instance_profile = var.instance_profile_name

}