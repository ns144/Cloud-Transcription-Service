variable "transcription_api_key" {
  description = "TRANSCRIPTION_SERVICE_API_KEY"
  type        = string
}

resource "aws_secretsmanager_secret" "api_key" {
 name = "transcription_service_api_key"
 recovery_window_in_days = 0
}


resource "aws_secretsmanager_secret_version" "api_key_version" {
 secret_id = aws_secretsmanager_secret.api_key.id
 secret_string = var.transcription_api_key
}