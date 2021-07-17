${jsonencode({
    "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [for instance in instances : [
          "AWS/EC2",
          "CPUUtilization",
          "InstanceId",
          "${instance.id}"
        ]]
        "period": 300,
        "stat": "Average",
        "region": "${region}",
        "title": "Instance Stats"
      }
    },
    {
      "type":"metric",
      "x": 13,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", "${lb}" ],
          [ ".", "ActiveConnectionCount", ".", "." ],
          [ ".", "RequestCount", ".", "." ],
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "New Api Connections",
        "stat": "Average",
        "period": 30,
        "legend": {
          "position": "hidden"
        }
      }
    }
  ]
})}