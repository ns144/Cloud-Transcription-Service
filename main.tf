resource "aws_s3_bucket" "transcript-bucket" {
  bucket_prefix = "transcript-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}