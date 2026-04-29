# ============================
# Route 53 Hosted Zone
# ============================
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ============================
# Application Alias Record
# ============================
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.app_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}