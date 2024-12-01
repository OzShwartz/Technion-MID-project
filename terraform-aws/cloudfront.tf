# CloudFront Distribution for ALB
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_lb.app__lb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for ALB with HTTP support"
  default_root_object = "/"

  # Default Cache Behavior for root
  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "allow-all"  # Allow both HTTP and HTTPS

    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}