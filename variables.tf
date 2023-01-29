variable "vpc_cidr" {
  type    = string
  default = "10.124.0.0/16"
}

variable "access_ip" {
  type    = string
  default = "0.0.0.0/0" # for using single IP address
  # type = list(string)
  # default = ["0.0.0.0/0"] # For using multiple IP Addresses
}

variable "main_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "main_vol_size" {
  type    = number
  default = 30
}

variable "main_instance_count" {
  type    = number
  default = 1
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}