resource "aws_api_gateway_rest_api" "harsh-viradia-api" {
  name = "harsh-viradia-wildrides-api"
  
}

resource "aws_api_gateway_resource" "harsh-viradia-api-resource" {
  rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
  parent_id = aws_api_gateway_rest_api.harsh-viradia-api.root_resource_id
  path_part = "ride"

  depends_on = [
    aws_api_gateway_rest_api.harsh-viradia-api,
  ]
}

resource "aws_api_gateway_authorizer" "harsh-viradia-api-authorozer" {
  rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
  name = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.harsh-viradia-user-pool.arn]
}

#-------------------------------------------------------------------- Option Method -----------------------------------------------------

resource "aws_api_gateway_method" "harsh-viradia-option-method" {
  rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
  resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "harsh-viradia-option-response" {
  rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
  resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
  http_method = aws_api_gateway_method.harsh-viradia-option-method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "harsh-viradia-option-integration" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = aws_api_gateway_method.harsh-viradia-option-method.http_method
    integration_http_method = "OPTIONS"
    content_handling = "CONVERT_TO_TEXT"
    type = "MOCK"
    uri = aws_lambda_function.harsh-viradia-lambda-function.invoke_arn
    request_templates = { "application/json" = "{\"statusCode\": 200}"}
}

resource "aws_api_gateway_integration_response" "harsh-viradia-option-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = aws_api_gateway_method.harsh-viradia-option-method.http_method
    status_code = aws_api_gateway_method_response.harsh-viradia-option-response.status_code

    response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
        aws_api_gateway_integration.harsh-viradia-integration
    ]
}

#-------------------------------------- POST ------------------------------

resource "aws_api_gateway_method" "harsh-viradia-post-method" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = "ANY"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.harsh-viradia-api-authorozer.id
}

resource "aws_api_gateway_method_response" "harsh-viradia-post-response" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = aws_api_gateway_method.harsh-viradia-post-method.http_method

    status_code = "200"
    response_models = {
        "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration" "harsh-viradia-integration" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = aws_api_gateway_method.harsh-viradia-post-method.http_method
    integration_http_method = "ANY"
    type = "AWS_PROXY"
    uri = aws_lambda_function.harsh-viradia-lambda-function.invoke_arn
}

resource "aws_api_gateway_integration_response" "harsh-viradia-post-integration" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    resource_id = aws_api_gateway_resource.harsh-viradia-api-resource.id
    http_method = aws_api_gateway_method.harsh-viradia-post-method.http_method
    status_code = aws_api_gateway_method_response.harsh-viradia-post-response.status_code
    
    response_templates = {"application/json" = ""}

    depends_on = [
      aws_api_gateway_integration.harsh-viradia-integration
    ]
}

#------------------------------------- Deploy ---------------------------

resource "aws_api_gateway_deployment" "harsh-viradia-deployment" {
    rest_api_id = aws_api_gateway_rest_api.harsh-viradia-api.id
    stage_name = "prod"
    depends_on = [
      aws_api_gateway_integration.harsh-viradia-integration
    ]
    triggers = {
      redeployment = sha1(jsonencode([
        aws_api_gateway_resource.harsh-viradia-api-resource.id,
        aws_api_gateway_method.harsh-viradia-post-method.id,
        aws_api_gateway_integration.harsh-viradia-integration.id,
      ]))
    }

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowAPIGatewayInvocation"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.harsh-viradia-lambda-function.arn}"
    principal     = "apigateway.amazonaws.com"
    source_arn    = "arn:aws:execute-api:us-east-1:587172484624:${aws_api_gateway_rest_api.harsh-viradia-api.id}/*/*/ride"
}