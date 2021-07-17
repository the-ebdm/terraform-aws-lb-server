resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = replace("${var.id}_system_dashboard", "_", "-")
  dashboard_body = templatefile("${path.module}/basefiles/dashboard.json.tpl", {
    brand_id  = var.id
    region    = "eu-west-2"
    instances = [aws_instance.instance]
    lbname    = aws_lb.api.name
  })
}