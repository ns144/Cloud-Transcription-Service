resource "aws_s3_bucket" "transcript-bucket" {
  bucket_prefix = "transcript-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_user" "s3_user" {
  name = "s3-access-user"
}

resource "aws_iam_group" "s3_access_group" {
  name = "s3-access-group"
}

resource "aws_iam_group_policy_attachment" "s3_access_attachment" {
  group      = aws_iam_group.s3_access_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_group_membership" "s3_user_membership" {
  user  = aws_iam_user.s3_user.name
  groups = [aws_iam_group.s3_access_group.name]
}

resource "aws_s3_bucket_policy" "transcript-bucket-policy" {
  bucket = aws_s3_bucket.transcript-bucket.bucket

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.s3_user.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.transcript-bucket.arn}",
        "${aws_s3_bucket.transcript-bucket.arn}/*"
      ]
    }
  ]
}
EOF
}