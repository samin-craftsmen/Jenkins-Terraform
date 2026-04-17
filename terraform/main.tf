# Discover all lambda subdirectories by looking for zip files produced by the build
locals {
  lambda_zips = fileset("${path.module}/../lambda", "*/function.zip")
  lambda_names = toset([for zip in local.lambda_zips : dirname(zip)])
}

# Reference the existing API Gateway
data "aws_apigatewayv2_api" "existing" {
  api_id = var.api_gateway_id
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = "jenkins-task-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ----- Lambda Functions -----

resource "aws_lambda_function" "functions" {
  for_each = local.lambda_names

  function_name = "jenkins-task-${each.value}"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["x86_64"]
  timeout       = 15
  memory_size   = 128

  filename         = "${path.module}/../lambda/${each.value}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/${each.value}/function.zip")

  depends_on = [aws_iam_role_policy_attachment.basic_execution]
}

# ----- API Gateway Integration -----

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambda_names

  api_id                 = var.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions[each.value].invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.lambda_names

  api_id    = var.api_gateway_id
  route_key = "ANY ${var.route_prefix}/${each.value}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.value].id}"
}

# ----- Lambda Permission for API Gateway -----

resource "aws_lambda_permission" "apigw" {
  for_each = local.lambda_names

  statement_id  = "AllowAPIGatewayInvoke-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.value].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_apigatewayv2_api.existing.execution_arn}/*/*"
}
