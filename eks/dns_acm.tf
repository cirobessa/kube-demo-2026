# ==============================================================================
# Auto-Descoberta da Conta AWS, Hosted Zone Route 53 e Certificado SSL/TLS ACM
# ==============================================================================

# 1. Identidade da Conta AWS
data "aws_caller_identity" "current" {}

# 2. Lista as Hosted Zones da conta atual
data "aws_route53_zones" "all" {}

data "aws_route53_zone" "all" {
  for_each = toset(data.aws_route53_zones.all.ids)
  zone_id  = each.value
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  # Filtra a zona pública do laboratório (*realhandsonlabs.net) com fallback para qualquer zona pública
  all_public_zones = [
    for z in data.aws_route53_zone.all : z
    if !z.private_zone
  ]

  rhol_zones = [
    for z in local.all_public_zones : z
    if can(regex("realhandsonlabs\\.net", z.name))
  ]

  lab_zones = length(local.rhol_zones) > 0 ? local.rhol_zones : local.all_public_zones

  has_lab_zone = length(local.lab_zones) > 0
  lab_zone_id  = local.has_lab_zone ? local.lab_zones[0].zone_id : ""
  lab_domain   = local.has_lab_zone ? trimsuffix(local.lab_zones[0].name, ".") : ""
}

# 3. Solicitação do Certificado SSL/TLS Wildcard no AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "lab_cert" {
  count = local.has_lab_zone ? 1 : 0

  domain_name               = "*.${local.lab_domain}"
  subject_alternative_names = [local.lab_domain]
  validation_method         = "DNS"

  tags = {
    Name = "${local.lab_domain}-wildcard-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 4. Registros CNAME de Validação DNS criados automaticamente no Route 53
resource "aws_route53_record" "cert_validation" {
  for_each = local.has_lab_zone ? {
    for dvo in aws_acm_certificate.lab_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.lab_zone_id
}

# 5. Conclusão e Espera da Validação do Certificado ACM
resource "aws_acm_certificate_validation" "lab_cert" {
  count = local.has_lab_zone ? 1 : 0

  certificate_arn         = aws_acm_certificate.lab_cert[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
