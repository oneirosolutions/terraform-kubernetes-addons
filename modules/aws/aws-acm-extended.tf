locals {

  aws-acm-extended = merge(
    {
      enabled                    = false
      zone_name                  = ""
      domain_name                = ""
      load_balancer_arn          = ""
      target_group_name          = ""
      backend_service_name       = "backend-lb"
      backend_port               = 80
      backend_target_port        = 4000
      backend_host_prefix        = "api"
      frontend_service_name      = "frontend-lb"
      frontend_port              = 80
      frontend_target_port       = 80      
      vpc_name                   = ""
      ingress_label_app          = ""
      ingress_label_pod_name     = ""
      ingress_label_fe_app       = ""
      ingress_label_fe_pod_name  = ""
      namespace                  = ""
      
    },
    var.aws-acm-extended
  )
#    lb_name               = split("-", split(".", kubernetes_ingress_v1.backend_ingress_extended[count.index].status.0.load_balancer.0.ingress.0.hostname).0).0

}

resource "kubernetes_ingress_v1" "backend_ingress_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    name = "backend-ingress"
    namespace = local.aws-acm-extended.namespace
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/group.name": local.aws-acm-extended.target_group_name
      "alb.ingress.kubernetes.io/group.order": "2"
      "alb.ingress.kubernetes.io/actions.ssl-redirect": <<JSON
{
  "Type": "redirect",
  "RedirectConfig": {
    "Protocol": "HTTPS",
    "Port": "443",
    "StatusCode": "HTTP_301"
  }
}
JSON
    }
    labels = {
      "app" : local.aws-acm-extended.ingress_label_app
      "app.kubernetes.io/name" : local.aws-acm-extended.ingress_label_pod_name
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "${local.aws-acm-extended.backend_host_prefix}.${local.aws-acm-extended.domain_name}"
      http {
        path {
          backend {
            service {
              name = "ssl-redirect"
              port {
                name  = "use-annotation"
              }
            }
          }

          path = "/*"
          path_type = "ImplementationSpecific"
        }        
        path {
          backend {
            service {
              name = local.aws-acm-extended.backend_service_name
              port {
                name = "http"
              }
            }
          }

          path = "/*"
          path_type = "ImplementationSpecific"
        }
   
      }
    }

    tls {
      hosts = ["${local.aws-acm-extended.backend_host_prefix}.${local.aws-acm-extended.domain_name}"]
    }
  }
}

resource "kubernetes_service" "backend-extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  metadata {
    name = local.aws-acm-extended.backend_service_name
    namespace = local.aws-acm-extended.namespace
    labels = {
      "app.kubernetes.io/instance" : local.aws-acm-extended.ingress_label_app
      "app.kubernetes.io/name" : local.aws-acm-extended.ingress_label_pod_name
    }
  }
  spec {
    port {
      name        = "http"
      port        = local.aws-acm-extended.backend_port
      target_port = local.aws-acm-extended.backend_target_port
      protocol    = "TCP"
    }
    selector = {
      "app.kubernetes.io/instance" : local.aws-acm-extended.ingress_label_app
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "frontend_ingress_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    name = "frontend-ingress"
    namespace = local.aws-acm-extended.namespace
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/group.name": local.aws-acm-extended.target_group_name
      "alb.ingress.kubernetes.io/group.order": "1"
      "alb.ingress.kubernetes.io/actions.ssl-redirect": <<JSON
{
  "Type": "redirect",
  "RedirectConfig": {
    "Protocol": "HTTPS",
    "Port": "443",
    "StatusCode": "HTTP_301"
  }
}
JSON
    }
    labels = {
      "app.kubernetes.io/instance" : local.aws-acm-extended.ingress_label_fe_app
      "app.kubernetes.io/name" : local.aws-acm-extended.ingress_label_fe_pod_name
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = local.aws-acm-extended.domain_name
      http {
        path {
          backend {
            service {
              name = "ssl-redirect"
              port {
                name  = "use-annotation"
              }
            }
          }

          path = "/*"
          path_type = "ImplementationSpecific"
        }        
        path {
          backend {
            service {
              name = local.aws-acm-extended.frontend_service_name
              port {
                name = "http"
              }
            }
          }

          path = "/*"
          path_type = "ImplementationSpecific"
        }
   
      }
    }

    tls {
      hosts = ["${local.aws-acm-extended.domain_name}"]
    }
  }
}

resource "kubernetes_service" "frontend_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  metadata {
    name = local.aws-acm-extended.frontend_service_name
    namespace = local.aws-acm-extended.namespace
    labels = {
      "app.kubernetes.io/instance" : local.aws-acm-extended.ingress_label_fe_app
      "app.kubernetes.io/name" : local.aws-acm-extended.ingress_label_fe_pod_name
    }
  }
  spec {
    port {
      name        = "http"
      port        = local.aws-acm-extended.frontend_port
      target_port = local.aws-acm-extended.frontend_target_port
      protocol    = "TCP"
    }
    selector = {
      "app.kubernetes.io/instance" : local.aws-acm-extended.ingress_label_fe_app
    }
    type = "NodePort"
  }
}


# data "aws_lb" "backend" {
#   tags = {
#     "ingress.k8s.aws/stack" = "default/backend-ingress"
#   }
# }

# output "load_balancer_name" {
#   value = data.aws_lb.backend
# }

resource "aws_acm_certificate" "dlx_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  domain_name               = local.aws-acm-extended.domain_name
  subject_alternative_names = ["*.${local.aws-acm-extended.domain_name}"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "dlx_digital_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  name         = local.aws-acm-extended.zone_name
  private_zone = false
}

# data "aws_lb_target_group" "backend_target_group" {
#   name         = local.aws-acm-extended.target_group_name
 
# }

# resource "aws_route53_record" "dlx_extended" {
#   for_each = {
#     for dvo in aws_acm_certificate.dlx_extended[count.index].domain_validation_options : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       record  = dvo.resource_record_value
#       type    = dvo.resource_record_type
#       zone_id = data.aws_route53_zone.dlx_digital_extended.zone_id
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = each.value.zone_id
# }

resource "aws_route53_record" "dlx_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.dlx_extended[count.index].domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.dlx_extended[count.index].domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.dlx_extended[count.index].domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.dlx_digital_extended[0].zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "dlx_extended" {
  count = local.aws-acm-extended["enabled"] ? 1 : 0
  certificate_arn         = aws_acm_certificate.dlx_extended[count.index].arn
  validation_record_fqdns = [for record in aws_route53_record.dlx_extended : record.fqdn]
}
