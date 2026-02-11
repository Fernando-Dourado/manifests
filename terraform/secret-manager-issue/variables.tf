variable "harness_account_id" {
  type        = string
  description = "Harness Account ID"
}
 
variable "harness_api_key" {
  type        = string
  sensitive   = true
  description = "Harness Platform API Key"
}
 
variable "org_id" {
  type    = string
  default = "default"
}
 
variable "project_id" {
  type = string
}
