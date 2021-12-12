#output "abc" {
#  value = "Hello\nWorld"
#}
#
#output "abc1" {
#  value = "100"
#}

variable "abc" {
  default = "100"
}
output "abc" {
  value = var.abc
}


