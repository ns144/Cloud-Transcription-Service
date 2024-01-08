variable "transcription_api_key" {
  description = "TRANSCRIPTION_SERVICE_API_KEY"
  type        = string
}

resource "aws_secretsmanager_secret" "transcription_service_api_key" {
 name = "transcription_service_api_key"
}


resource "aws_secretsmanager_secret_version" "transcription_service_api_key_version" {
 secret_id = aws_secretsmanager_secret.transcription_service_api_key.id
 secret_string = var.transcription_api_key
}