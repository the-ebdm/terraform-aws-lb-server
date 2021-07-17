{
	"agent": {
		"metrics_collection_interval": 30,
		"run_as_user": "root"
	},
	"logs": {
		"logs_collected": {
			"files": {
				"collect_list": [
					{
						"file_path": "/var/log/auth.log",
						"log_group_name": "/lb_server/auth_log",
						"log_stream_name": "${id}"
					},
					{
						"file_path": "/var/log/cloud-init-output.log",
						"log_group_name": "/lb_server/cloud_init_output",
						"log_stream_name": "${id}"
					}
				]
			}
		}
	}
}