data "archive_file" "lambda_package" {

  type = "zip"

  source_file = "index.py"

  output_path = "index.zip"

}

resource "aws_lambda_function" "start_lambda" {

  filename = "index.zip"

  function_name = "startTranscriptionFunction"

  role = aws_iam_role.lambda_role.arn

  handler = "index.lambda_handler"

  runtime = "python3.10"

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
        INSTANCE_ID = aws_instance.transcription_server.id
        SECRET = var.transcription_api_key
    }
  }

  timeout = 60
}

output "instance_id" {
  value = aws_instance.transcription_server.id
}

resource "aws_iam_role" "lambda_role" {

  name = "lambda-role"



  assume_role_policy = jsonencode({

    Version = "2012-10-17",

    Statement = [

    {

      Action = "sts:AssumeRole",

      Effect = "Allow",

      Principal = {

        Service = "lambda.amazonaws.com"

      }

    }

  ]

})

}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function to start EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:StartInstances"
      ],
      Resource = ["arn:aws:ec2:*:*:instance/*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  #policy_arn = "arn:aws:iam::aws:policy/"
  #policy_arn = aws_iam_policy.lambda_policy.arn
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ])

  role = aws_iam_role.lambda_role.name
  policy_arn = each.value
}



resource "aws_lambda_permission" "apigw_lambda" {

  statement_id = "AllowExecutionFromAPIGateway"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.start_lambda.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.transcription_gateway.execution_arn}/*/*/*"

}