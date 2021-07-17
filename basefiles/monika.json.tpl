{
  "notifications": [
    {
      "id": "042c4e49-6c9e-4985-a6aa-c4d68983d998",
      "type": "discord",
      "data": {
        "url": "https://discord.com/api/webhooks/857571409218502666/HcnFyRgiCf4TSFNV48Fo20PCz9to9suUTbgAHiOeWZPClukEXQim0GANOrTSaEAyXes6"
      }
    }
  ],
  "probes": [
    {
      "id": "7fc50dd6-d839-4096-b330-bc976fd3f794",
      "name": "Api: Can login",
      "requests": [
        {
          "method": "POST",
          "url": "https://${var.api_domain}/admin/authenticate",
          "timeout": 500,
          "headers": {
            "Content-Type": "application/json"
          },
          "body": {
            "email": "admin@franscape.io",
            "password": "mky7qgXdddmF"
          }
        }
      ],
      "incidentThreshold": 5,
      "recoveryThreshold": 5,
      "alerts": [
        "status-not-2xx"
      ]
    }
  ]
}