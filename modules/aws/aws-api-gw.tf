locals {

  aws-api-gw = merge(
    {
      backend_host_prefix        = "api"
      domain_name                = [""]
      enabled                    = false
      gateway_api_name           = [""]
      load_balancer_arn          = ""
      load_balancer_dns          = [""]
      namespace                  = [""]
      zone_name                  = "dlx.digital"
      
    },
    var.aws-api-gw
  )
api-gw-dvos = local.aws-api-gw["enabled"] ?  aws_acm_certificate.api_gw_dlx[0].domain_validation_options :[]
api-gw-dvos2 = local.aws-api-gw["enabled"] ?  toset(aws_acm_certificate.api_gw_dlx[*].domain_validation_options) :[]
api-gw-dvos3 = flatten(
    [for first_step_value in aws_acm_certificate.api_gw_dlx :
      [for second_step_value in first_step_value.domain_validation_options : second_step_value]
  ])
}

resource "aws_api_gateway_vpc_link" "main" {
 count = local.aws-api-gw["enabled"] ? 1 : 0
 name = "api_gateway_vpclink"
 description = "Api Gateway VPC Link. Managed by Terraform."
 target_arns = [local.aws-api-gw.load_balancer_arn]
}

resource "aws_api_gateway_rest_api" "main" {
 count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
 name = flatten(local.aws-api-gw.*.gateway_api_name)[count.index]
 description = "Api Gateway used for EKS. Managed by Terraform."
 endpoint_configuration {
   types = ["REGIONAL"]
 }
}

resource "aws_api_gateway_method" "main_forward_slash" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
  resource_id   = aws_api_gateway_rest_api.main[count.index].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"           = true
  }
}

resource "aws_api_gateway_integration" "main_forward_slash" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id = aws_api_gateway_rest_api.main[count.index].id
  resource_id = aws_api_gateway_rest_api.main[count.index].root_resource_id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://${flatten(local.aws-api-gw.*.load_balancer_dns)[count.index]}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main[0].id
  
  depends_on = [aws_api_gateway_method.main_forward_slash]
}

resource "aws_api_gateway_method_response" "main_forward_slash_200" {
    count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
    rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
    resource_id   = aws_api_gateway_rest_api.main[count.index].root_resource_id
    http_method   = "${aws_api_gateway_method.main_forward_slash[count.index].http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    depends_on = [aws_api_gateway_method.main_forward_slash]
}

resource "aws_api_gateway_resource" "proxy" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id = aws_api_gateway_rest_api.main[count.index].id
  parent_id   = aws_api_gateway_rest_api.main[count.index].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
  resource_id   = aws_api_gateway_resource.proxy[count.index].id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"           = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id = aws_api_gateway_rest_api.main[count.index].id
  resource_id = aws_api_gateway_resource.proxy[count.index].id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "https://${flatten(local.aws-api-gw.*.load_balancer_dns)[count.index]}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main[0].id
}

resource "aws_api_gateway_method_response" "proxy" {
    count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
    rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
    resource_id   = aws_api_gateway_resource.proxy[count.index].id
    http_method   = "${aws_api_gateway_method.proxy[count.index].http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true,
        "method.response.header.Access-Control-Expose-Headers" = true,
        "method.response.header.Access-Control-Max-Age" = true
    }
    depends_on = [aws_api_gateway_method.proxy]
}

resource "aws_api_gateway_method" "options_method" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
  resource_id   = aws_api_gateway_resource.proxy[count.index].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
    count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
    rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
    resource_id   = aws_api_gateway_resource.proxy[count.index].id
    http_method   = "${aws_api_gateway_method.options_method[count.index].http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true,
        "method.response.header.Access-Control-Expose-Headers" = true,
        "method.response.header.Access-Control-Max-Age" = true
    }
    depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
  resource_id   = aws_api_gateway_resource.proxy[count.index].id
  http_method   = "${aws_api_gateway_method.options_method[count.index].http_method}"
  type          = "MOCK"
  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
    rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
    resource_id   = aws_api_gateway_resource.proxy[count.index].id
    http_method   = "${aws_api_gateway_method.options_method[count.index].http_method}"
    status_code   = "${aws_api_gateway_method_response.options_200[count.index].status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'",
        "method.response.header.Access-Control-Max-Age" = "'86400'"
        
    }
    depends_on = [aws_api_gateway_method_response.options_200]
}

resource "aws_api_gateway_deployment" "prod" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  rest_api_id = aws_api_gateway_rest_api.main[count.index].id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy[count.index].id,
      aws_api_gateway_method.proxy[count.index].id,
      aws_api_gateway_integration.proxy[count.index].id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  deployment_id = aws_api_gateway_deployment.prod[count.index].id
  rest_api_id   = aws_api_gateway_rest_api.main[count.index].id
  stage_name    = "prod"
}

resource "aws_acm_certificate" "api_gw_dlx" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.domain_name)) : 0
  domain_name               = flatten(local.aws-api-gw.*.domain_name)[count.index]
  subject_alternative_names = ["${local.aws-api-gw.backend_host_prefix}.${flatten(local.aws-api-gw.*.domain_name)[count.index]}"]
  validation_method         = "DNS"
}



data "aws_route53_zone" "api_gw_dlx_digital" {
  count =  local.aws-api-gw["enabled"] ? 1 : 0
  name         = local.aws-api-gw.zone_name
  private_zone = false
}

# resource "aws_route53_record" "api_gw_dlx" {
#   for_each = {
#     for dvo in local.api-gw-dvos2 : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       record  = dvo.resource_record_value
#       type    = dvo.resource_record_type
#       zone_id = data.aws_route53_zone.api_gw_dlx_digital[0].zone_id
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = each.value.zone_id
# }

# resource "aws_route53_record" "api_gw_dlx" {
#   for_each = tolist(aws_acm_certificate.api_gw_dlx[*])
#   allow_overwrite = true
#   name            = tolist(each.value.domain_validation_options)[0].resource_record_name
#   records         = [tolist(each.value.domain_validation_options)[0].resource_record_value]
#   ttl             = 60
#   type            = tolist(each.value.domain_validation_options)[0].resource_record_type
#   zone_id         = data.aws_route53_zone.api_gw_dlx_digital[0].zone_id
# }

# resource "aws_route53_record" "api_gw_dlx" {
#   for_each = {
#     for dvo in aws_acm_certificate.api_gw_dlx[0].domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.api_gw_dlx_digital[0].zone_id
# }


resource "aws_route53_record" "api_gw_dlx" {
  for_each = { for domain in local.api-gw-dvos3  : domain.domain_name => domain }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  type            = each.value.resource_record_type
  ttl             = 60
  zone_id         = data.aws_route53_zone.api_gw_dlx_digital[0].zone_id

  depends_on = [aws_acm_certificate.api_gw_dlx]
}

resource "aws_acm_certificate_validation" "api_gw_dlx" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  certificate_arn         = aws_acm_certificate.api_gw_dlx[floor((count.index / 2))].arn
  validation_record_fqdns = [for record in aws_route53_record.api_gw_dlx : record.fqdn]
}

output "cert-validation_cnt" {
 //value =  flatten(local.aws-acm-extended.*.domain_name)[0]
  value = length(flatten(aws_acm_certificate_validation.api_gw_dlx))
}
output "cert-cnt" {
 //value =  flatten(local.aws-acm-extended.*.domain_name)[0]
  value = length(flatten(aws_acm_certificate.api_gw_dlx))
}

output "gvo2-cnt" {
 //value =  flatten(local.aws-acm-extended.*.domain_name)[0]
  value = flatten(local.api-gw-dvos2)
}

resource "aws_api_gateway_domain_name" "domain_name" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  domain_name = flatten(local.aws-api-gw.*.load_balancer_dns)[count.index]
  regional_certificate_arn = aws_acm_certificate_validation.api_gw_dlx[count.index].certificate_arn
  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  api_id      = aws_api_gateway_rest_api.main[count.index].id
  stage_name  = aws_api_gateway_stage.prod[count.index].stage_name
  domain_name = aws_api_gateway_domain_name.domain_name[count.index].domain_name
}

resource "aws_route53_record" "service_domains" {
  count = local.aws-api-gw["enabled"] ? length(flatten(local.aws-api-gw.*.load_balancer_dns)) : 0
  name    = flatten(local.aws-api-gw.*.load_balancer_dns)[count.index]
  type    = "A"
  zone_id = data.aws_route53_zone.api_gw_dlx_digital[0].zone_id
  alias {
    name                   = aws_api_gateway_domain_name.domain_name[count.index].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name[count.index].regional_zone_id
    evaluate_target_health = false
  }
}