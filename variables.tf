variable "archive" {
  description = "Must be a data source archive"
}

variable "domain" {
  type = string
}

variable "subdomain" {
  default = ""
}

variable "ami_id" {
  default = "ami-03397edfc64482efd"
  type    = string
}