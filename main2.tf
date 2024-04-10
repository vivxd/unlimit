provider "aws" {
  region = "your_aws_region"
}

variable "schedule" {
  default = "cron(0 8 ? * MON-FRI *)"  # Start at 08:00 UTC on weekdays
}

variable "tag" {
  default = "AutoStartStop"
}

resource "aws_iam_policy" "ec2_start_stop_policy" {
  name        = "EC2StartStopPolicy"
  description = "Policy for starting and stopping EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "arn:aws:ec2:*:*:instance/*",
        Condition = {
          StringEquals = {
            "aws:RequestTag/${var.tag}" = "true"
          },
          "Bool": {
            "aws:ResourceTag/${var.tag}" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_start_stop_policy_attachment" {
  name       = "EC2StartStopPolicyAttachment"
  roles      = ["your_iam_role"]
  policy_arn = aws_iam_policy.ec2_start_stop_policy.arn
}

resource "aws_cloudwatch_event_rule" "start_ec2_instances" {
  name                = "StartEC2Instances"
  description         = "Start EC2 instances on schedule"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "start_ec2_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2_instances.name
  target_id = "StartEC2InstancesTarget"
  arn       = "arn:aws:lambda:your_aws_region:your_account_id:function:start_ec2_instances_lambda_function"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:your_aws_region:your_account_id:function:start_ec2_instances_lambda_function"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2_instances.arn
}

resource "aws_cloudwatch_event_rule" "stop_ec2_instances" {
  name                = "StopEC2Instances"
  description         = "Stop EC2 instances on schedule"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "stop_ec2_target" {
  rule      = aws_cloudwatch_event_rule.stop_ec2_instances.name
  target_id = "StopEC2InstancesTarget"
  arn       = "arn:aws:lambda:your_aws_region:your_account_id:function:stop_ec2_instances_lambda_function"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda_stop" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:your_aws_region:your_account_id:function:stop_ec2_instances_lambda_function"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_instances.arn
}
