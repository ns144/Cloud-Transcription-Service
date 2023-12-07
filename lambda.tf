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