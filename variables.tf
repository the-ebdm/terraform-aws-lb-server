variable "id" {
  type = string
}
variable "user_data" {
  type = string
}
variable "domain" {
  type = string
}
variable "zone_id" {
  type = string
}
variable "ingress_ip" {
  type = string
}
variable "subdomain" {
  default = ""
}
variable "ami_id" {
  default = "ami-0194c3e07668a7e36"
  type    = string
}

variable "cost_alarm_threshold" {
  default = "10"
}
variable "cost_alarm_emai" {
  default = ""
}

variable "cert_arn" {
  default = ""
}

variable "ssh_pubkey" {
  default = ""
}

variable "port" {
  default = 80 
}

variable "tskey" {
  default = ""
	type = string
	description = "Tailscale Authentication Key"	
}

variable "sns_arn" {
  default = "arn:aws:sns:eu-west-2:736462105110:discord-notifications"
}