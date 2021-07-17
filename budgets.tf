resource "aws_budgets_budget" "ec2" {
	count = var.cost_alarm_emai != "" ? 1 : 0
  name              = "budget-ec2-monthly"
  budget_type       = "COST"
  limit_amount      = var.cost_alarm_threshold
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    Service = "Amazon Elastic Compute Cloud - Compute"
		TagKeyValue = "Project=${var.id}"
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.cost_alarm_emai]
  }
}