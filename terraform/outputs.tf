output "lambda_function_names" {
  description = "Names of deployed Lambda functions"
  value       = { for k, v in aws_lambda_function.functions : k => v.function_name }
}

output "api_routes" {
  description = "API Gateway routes created"
  value       = { for k, v in aws_apigatewayv2_route.lambda : k => v.route_key }
}

output "lambda_execution_role_arn" {
  description = "Terraform-managed Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution.arn
}
