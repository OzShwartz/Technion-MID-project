resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = var.s3_bucket_name
  acl    = "log-delivery-write"
  region = var.AWS_REGION
}

resource "aws_s3_bucket_acl" "cloudfront_logs_acl" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "cloudfront_logs_policy" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:PutObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.cloudfront_logs.arn}/*"
        Principal = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
          }
        }
      }
    ]
  })
}
