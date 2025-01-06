data "archive_file" "lambda_stop_package" {

  type = "zip"

  source_file = "lambdas/stop_lambda.py"

  output_path = "stop_lambda.zip"

}

resource "aws_lambda_function" "stop_lambda" {

  filename = "stop_lambda.zip"

  function_name = "stopEC2Function"

  role = aws_iam_role.lambda_role.arn

  handler = "stop_lambda.lambda_handler"

  runtime = "python3.10"

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
        SECRET = var.transcription_api_key
    }
  }

  timeout = 60
}

resource "aws_iam_policy" "stop_lambda_policy" {
  name        = "stop_lambda_policy"
  description = "Policy for Lambda function to stop EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:StopInstances"
      ],
      Resource = ["arn:aws:ec2:*:*:instance/*"]
    }]
  })
}

resource "aws_lambda_permission" "stop_apigw_lambda" {

  statement_id = "AllowExecutionFromAPIGateway"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.stop_lambda.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.stop_ec2_gateway.execution_arn}/*/*/*"

}