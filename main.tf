resource "aws_dynamodb_table" "messages" {
    name = "sre-messages"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
        name = "id"
        type = "S"
    }

    tags = {
        Project = "sre-7day"
        Owner = "akash"
    }
}

# Creating Roles and Policy

resource "aws_iam_role" "lambda_role" {
    name = "sre-lambda-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = { Service = "lambda.amazonaws.com" },
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
    name = "lambda-dynamodb-policy"
    role = aws_iam_role.lambda_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
                "dynamodb:PutItem"
            ],
            Resource = aws_dynamodb_table.messages.arn
        }]
    })
}

# Lambda Resource

resource "aws_lambda_function" "api_lambda" {
    function_name = "sre-api-lambda"
    role = aws_iam_role.lambda_role.arn
    handler = "handler.handler"
    runtime = "python3.12"

    filename = "${path.module}/lambda/function.zip"
    source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

    environment {
        variables = {
            TABLE_NAME = aws_dynamodb_table.messages.name
        }
    }
}

# Add API Gateway

resource "aws_apigatewayv2_api" "http_api" {
    name  = "sre-http-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.http_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.api_lambda.invoke_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_route" {
    api_id = aws_apigatewayv2_api.http_api.id
    route_key = "POST /message"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
    api_id = aws_apigatewayv2_api.http_api.id
    name = "$default"
    auto_deploy = true
}



resource "aws_lambda_permission" "allow_apigw" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.api_lambda.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}