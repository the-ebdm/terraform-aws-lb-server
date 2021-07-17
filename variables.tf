variable "id" {
  type = string
}
variable "archive" {
  description = "Must be a data source archive"
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