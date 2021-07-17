resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = replace("${var.id}_system_dashboard", "_", "-")
  dashboard_body = templatefile("${path.module}/basefiles/dashboard.json.tpl", {
    brand_id  = var.id
    region    = "eu-west-2"
    instances = [aws_instance.instance]
    lbname    = aws_lb.api.name
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name                = "${var.id}_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  metric_query {
    id = "m1"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = "app/web"
      }
    }
  }
}