resource "aws_api_gateway_rest_api" "transcription_gateway" {

  name = "transcription-api"

  description = "API Endpoint for Transcription"



  endpoint_configuration {

    types = ["REGIONAL"]

  }

}

resource "aws_api_gateway_resource" "root" {

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id

  parent_id = aws_api_gateway_rest_api.transcription_gateway.root_resource_id

  path_part = "start_transcription"

}

resource "aws_api_gateway_method" "proxy" {

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = "POST"

  authorization = "NONE"

}



resource "aws_api_gateway_integration" "lambda_integration" {

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"

  type = "MOCK"

}



resource "aws_api_gateway_method_response" "proxy" {

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.proxy.http_method

  status_code = "200"

}



resource "aws_api_gateway_integration_response" "proxy" {

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.proxy.http_method

  status_code = aws_api_gateway_method_response.proxy.status_code



  depends_on = [

    aws_api_gateway_method.proxy,

    aws_api_gateway_integration.lambda_integration

  ]

}

//options
resource "aws_api_gateway_method" "options" {
  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "OPTIONS"
  #   authorization = "NONE"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.transcription_gateway.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.options,
    aws_api_gateway_integration.options_integration,
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration, # Add this line
  ]

  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id
  stage_name  = "dev"
}

# // domain
resource "aws_acm_certificate" "transcription_gateway_cert" {
  domain_name               = "api.sumeet.life"
  provider                  = aws.aws_useast1
  subject_alternative_names = ["api.sumeet.life"] # Your custom domain
  validation_method         = "DNS"
}

resource "aws_api_gateway_domain_name" "gw_domain" {
  certificate_arn = aws_acm_certificate.transcription_gateway_cert.arn
  domain_name     = "api.sumeet.life"
  security_policy = "TLS_1_2"
}

resource "aws_api_gateway_base_path_mapping" "gw_mapping" {
  domain_name = "api.sumeet.life"
  api_id      = aws_api_gateway_rest_api.transcription_gateway.id
  stage_name  = "dev" # Adjust as needed
}