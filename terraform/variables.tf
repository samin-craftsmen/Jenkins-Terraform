variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "api_gateway_id" {
  description = "Existing API Gateway ID"
  type        = string
  default     = "pr807w8a23"
}

variable "route_prefix" {
  description = "Route prefix for API Gateway"
  type        = string
  default     = "/jenkins-task"
}
