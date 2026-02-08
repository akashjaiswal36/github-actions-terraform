output "dynamodb_table_name" {
    value = aws_dynamodb_table.messages.name
}

output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
