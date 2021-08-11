provider "aws" {
  region = "us-east-2"
  profile = "default" 
}

# SSH Key for remote access to web server instances.
# Used in aws_launch_configuration.
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.identifier}-ssh-key"
  public_key = "${var.public_key}"
}

# AWS Launch configuration for auto scaling group.
resource "aws_launch_configuration" "lc" {
  name_prefix     = "${var.identifier}-lc"
  image_id        = "${var.aws_ami}"
  instance_type   = "${var.aws_size}"
  key_name        = "${var.identifier}-ssh-key"
  security_groups = [aws_security_group.sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# The security group allows HTTP in and everything out.
resource "aws_security_group" "sg" {
  name        = "${var.identifier}-sg"
  description = "Http and SSH traffic."

  # SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Database access.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.identifier}-sg"
  }

}

# @todo Temporarily removed below - can be readded when https://github.com/hashicorp/terraform/issues/15300 is fixed?

# Attach an SSH access rule  to the security group if remote_access=true
#resource "aws_security_group_rule" "ssh_access" {
 # type            = "ingress"
  #from_port       = 22
  #to_port         = 22
  #protocol        = "tcp"
  #cidr_blocks     = ["0.0.0.0/0"]

  #security_group_id = aws_security_group.sg.id

  # This logic determines if 0 (disabled) or 1 (enabled) SSH inbound
  # rules are added to the security group.
   #count = "${var.remote_access == "true" ? 1 : 0}"
#}

#
# Autoscaling Group and Load Balancer.
#


# AWS Autoscaling group
resource "aws_autoscaling_group" "asg" {
  availability_zones   = ["us-east-2a","us-east-2b"]
  name                 = "${var.identifier}-web-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = aws_launch_configuration.lc.name
  load_balancers       = [aws_elb.drupal_elb.name]
  health_check_type    = "ELB"

}

# AWS Load balancer
resource "aws_elb" "drupal_elb" {
  name = "${var.identifier}-web-lb"
  # The same availability zone as our instances
  security_groups      = [aws_security_group.sg.id]
  availability_zones   = ["us-east-2a", "us-east-2b"]
  health_check {
   target = "HTTP:80/"
   interval = 15
   timeout = 3
   healthy_threshold = 2
   unhealthy_threshold = 2
   }

  listener {
   instance_port = 80
   instance_protocol = "http"
   lb_port = 80
   lb_protocol = "http"
  }

  tags = {
    Name = "${var.identifier}-web-lb"
  }
}

data "aws_vpc" "default" {
    filter {
        name = "isDefault"
        values = ["true"]
    }
}

data "aws_subnet_ids" "subnets" {
    vpc_id = data.aws_vpc.default.id
} 

# RDS.

resource "aws_db_instance" "rds" {
  depends_on             = [aws_security_group.sg]
  identifier             = "${var.identifier}-rds"
  allocated_storage      = "5"
  engine                 = "mysql"
  instance_class         = "db.t2.micro"
  name                   = "${var.db_name}"
  username               = "${var.db_username}"
  password               = "${var.db_pass}"
  vpc_security_group_ids = [aws_security_group.sg.id]
  skip_final_snapshot    = true
  final_snapshot_identifier = "testing"
}
