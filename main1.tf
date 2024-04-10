provider "aws" {
  region = "your_aws_region"
}

variable "schedule" {
  default = "cron(0 8 ? * MON-FRI *)"  # Start at 08:00 on weekdays (UTC)
}

variable "tag_key" {
  default = "AutoStartStop"
}

resource "aws_instance" "ec2_instance" {
  ami           = "your_ami_id"
  instance_type = "your_instance_type"

  tags = {
    ${var.tag_key} = "true"
  }
}

resource "aws_autoscaling_schedule" "start_schedule" {
  scheduled_action_name  = "start"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = var.schedule
  autoscaling_group_name = aws_instance.ec2_instance.tags[var.tag_key]
  desired_capacity       = 1
}

resource "aws_autoscaling_schedule" "stop_schedule" {
  scheduled_action_name  = "stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.schedule
  autoscaling_group_name = aws_instance.ec2_instance.tags[var.tag_key]
}
