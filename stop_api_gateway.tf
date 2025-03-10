resource "aws_api_gateway_rest_api" "stop_ec2_gateway" {

  name = "stop_ec2-api"

  description = "API Endpoint top stop the EC2"



  endpoint_configuration {

    types = ["REGIONAL"]

  }

}

#resource "aws_api_gateway_authorizer" "api_auth" {
#
#  name = "transcription_gatewayg_authorizer2"
#
#  rest_api_id = aws_api_gateway_rest_api.transcription_gateway.id
#
#  type = "COGNITO_USER_POOLS"
#
#  provider_arns = [aws_cognito_user_pool.api_user_pool.arn]
#
#}

resource "aws_api_gateway_resource" "stop_root" {

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id

  parent_id = aws_api_gateway_rest_api.stop_ec2_gateway.root_resource_id

  path_part = "stop_ec2"

}

resource "aws_api_gateway_method" "stop_proxy" {

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id

  resource_id = aws_api_gateway_resource.stop_root.id

  http_method = "GET"
  
  authorization = "NONE"

  #authorization = "COGNITO_USER_POOLS"

  #authorizer_id = aws_api_gateway_authorizer.api_auth.id


}



resource "aws_api_gateway_integration" "stop_lambda_integration" {

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id

  resource_id = aws_api_gateway_resource.stop_root.id

  http_method = aws_api_gateway_method.stop_proxy.http_method

  integration_http_method = "POST"

  type = "AWS_PROXY"
  uri = aws_lambda_function.stop_lambda.invoke_arn

}



resource "aws_api_gateway_method_response" "stop_proxy" {

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id

  resource_id = aws_api_gateway_resource.stop_root.id

  http_method = aws_api_gateway_method.stop_proxy.http_method

  status_code = "200"

    //cors section

  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" = true,

    "method.response.header.Access-Control-Allow-Methods" = true,

    "method.response.header.Access-Control-Allow-Origin" = true

  }

}



resource "aws_api_gateway_integration_response" "stop_proxy" {

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id

  resource_id = aws_api_gateway_resource.stop_root.id

  http_method = aws_api_gateway_method.stop_proxy.http_method

  status_code = aws_api_gateway_method_response.stop_proxy.status_code

  //cors

  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",

    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

  }

  depends_on = [

    aws_api_gateway_method.stop_proxy,

    aws_api_gateway_integration.stop_lambda_integration

  ]

}

resource "aws_api_gateway_deployment" "stop_deployment" {
  depends_on = [
    aws_api_gateway_integration.stop_lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.stop_ec2_gateway.id
}

resource "aws_api_gateway_stage" "stop_dev" {
  deployment_id = aws_api_gateway_deployment.stop_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.stop_ec2_gateway.id
  stage_name    = "dev"
}