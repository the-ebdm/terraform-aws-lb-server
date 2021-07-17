resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = replace("${var.id}_system_dashboard", "_", "-")
  dashboard_body = templatefile("${path.module}/basefiles/dashboard.json.tpl", {
    brand_id  = var.id
    region    = "eu-west-2"
    instances = [aws_instance.instance]
    lb    = aws_lb.api.arn_suffix
  })
}

# resource "aws_cloudwatch_metric_alarm" "errors" {
#   alarm_name                = "${var.id}_api_errror_alarm"
#   comparison_operator       = "GreaterThanOrEqualToThreshold"
#   evaluation_periods        = "2"
#   threshold                 = "10"
#   alarm_description         = "This metric monitors ec2 cpu utilization"
#   insufficient_data_actions = []
#   metric_query {
#     id = "m1"

#     metric {
#       metric_name = "HTTPCode_ELB_5XX_Count"
#       namespace   = "AWS/ApplicationELB"
#       period      = "120"
#       stat        = "Sum"
#       unit        = "Count"

#       dimensions = {
#         LoadBalancer = aws_lb.api.arn_suffix
#       }
#     }
#   }

#   metric_query {
#     id = "m2"
#     metric {
#       metric_name = "HTTPCode_ELB_4XX_Count"
#       namespace   = "AWS/ApplicationELB"
#       period      = "120"
#       stat        = "Sum"
#       unit        = "Count"

#       dimensions = {
#         LoadBalancer = aws_lb.api.arn_suffix
#       }
#     }
#   }
# }

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name                = "${var.id}_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ var.sns_arn ]
  insufficient_data_actions = [ var.sns_arn ] 

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        InstanceId = aws_instance.instance.id
      }
    }
  }
}