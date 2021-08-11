variable "identifier" {
  description = "label resource"
  default = "drupal"
}

variable "public_key" {
 description = " key that will be deployed to web servers, no default value"
 default =  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8Qj6e+B57oQIG02r9B8lrDdDnHVMRjw7xTyez8TGu/C1JVKx9+yFAavVeGM+JGB2WzLlxMKPYihlEfRxjx+UoUEa9fBkpl5LaQ5ErP3sYawP4rsC7ECPhJcns0wwNGg26xA9mYNZNXbBQ9G50ZVualULt5/ZmHAnBPlKldW1MujiCuysbMdPSWyAccbP93AKePlSZaNQle9xvffRrniwlPfF4PpI/4p9UdT5fOVWmXoclHRG1eWTrxzgynUU6Hms70icgQLMBeK0eKSCVPSsQSdTjuqnWAo1c2NLpy2diVONJ0vOaS1UrsVm8CiW6WAATyewLBrHiG56Gc04ncYrlbg7Gw+0rkJHRp2KquSDGGxQqabI9cBDUk9eMGn3QmYWLK29PINXoacfjYQSMIAz4Wl1xXTILQQ6tcVL2xmaJpr8zHFX0R8knhIHVcTcTW8BLd5O0PM2OwTqujKrtQAqNWUlhxBnIi1+4uVWuqtOqfqm70Hf3VbCl7UyTPLLzhLk="
}

variable "aws_ami" {
  description = "ami for asg"
  default = "ami-00399ec92321828f5"
}

variable "aws_size" {
  description = "type of instance"
  default = "t2.micro"
}

variable "remote_access" {
  description = "allow ssh accesss or not"
  default = "true"
}

variable "db_name" {
  description = "name of db"
  default = "drupal"
}

variable "db_username" {
  description = "db username"
  default = "drupal_user"
}

variable "db_pass" {
  description = "password for db"
  default = "drupal_pass"
}

variable "asg_min" {
  description = "min servers"
  default = "1"
}

variable "asg_max" { 
  description = "max servers"
  default = "2"
}

variable "asg_desired" {
  description = "desired servers"
  default = "1"
}
