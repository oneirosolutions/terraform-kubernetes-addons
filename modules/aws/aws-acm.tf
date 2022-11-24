locals {

  aws-acm = merge(
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
      
    },
    var.aws-acm
  )
    lb_name               = split("-", split(".", kubernetes_ingress_v1.backend_ingress.status.0.load_balancer.0.ingress.0.hostname).0).0

}

resource "kubernetes_ingress_v1" "backend_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "backend-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/group.name": "shared"
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
      "app" : local.aws-acm.ingress_label_app
      "app.kubernetes.io/name" : local.aws-acm.ingress_label_pod_name
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "${local.aws-acm.backend_host_prefix}.${local.aws-acm.domain_name}"
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
              name = local.aws-acm.backend_service_name
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
      hosts = ["${local.aws-acm.backend_host_prefix}.${local.aws-acm.domain_name}"]
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = local.aws-acm.backend_service_name
    labels = {
      "app" : local.aws-acm.ingress_label_app
      "app.kubernetes.io/name" : local.aws-acm.ingress_label_pod_name
    }
  }
  spec {
    port {
      name        = "http"
      port        = local.aws-acm.backend_port
      target_port = local.aws-acm.backend_target_port
      protocol    = "TCP"
    }
    selector = {
      "app" : local.aws-acm.ingress_label_app
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "frontend-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/group.name": "shared"
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
      "app" : local.aws-acm.ingress_label_fe_app
      "app.kubernetes.io/name" : local.aws-acm.ingress_label_fe_pod_name
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = local.aws-acm.domain_name
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
              name = local.aws-acm.frontend_service_name
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
      hosts = ["${local.aws-acm.domain_name}"]
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = local.aws-acm.frontend_service_name
    labels = {
      "app" : local.aws-acm.ingress_label_fe_app
      "app.kubernetes.io/name" : local.aws-acm.ingress_label_fe_pod_name
    }
  }
  spec {
    port {
      name        = "http"
      port        = local.aws-acm.frontend_port
      target_port = local.aws-acm.frontend_target_port
      protocol    = "TCP"
    }
    selector = {
      "app" : local.aws-acm.ingress_label_fe_app
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

resource "aws_acm_certificate" "dlx" {
  domain_name               = local.aws-acm.domain_name
  subject_alternative_names = ["*.${local.aws-acm.domain_name}"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "dlx_digital" {
  name         = local.aws-acm.zone_name
  private_zone = false
}

# data "aws_lb_target_group" "backend_target_group" {
#   name         = local.aws-acm.target_group_name
 
# }

resource "aws_route53_record" "dlx" {
  for_each = {
    for dvo in aws_acm_certificate.dlx.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.dlx_digital.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "dlx" {
  certificate_arn         = aws_acm_certificate.dlx.arn
  validation_record_fqdns = [for record in aws_route53_record.dlx : record.fqdn]
}

# resource "aws_lb_target_group" "backend_tg" {
#   name        = "backend-lb-tg"
#   port        = local.aws-acm.backend_port
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = data.aws_vpc.main.id
# }

# data "aws_lb_target_group" "backend_tg" {
#   name         = "backend-lb-tg"
# }

data "aws_vpc" "main" {
 filter {
     name = "tag:Name"
     values =[local.aws-acm.vpc_name]
   }
}

output "data_vpc_name" {
  value = data.aws_vpc.main.id
}

/* resource "aws_lb_listener" "dlx" {
  port = "443"
  protocol = "HTTPS"
  load_balancer_arn = data.aws_lb.backend.arn
  certificate_arn   = aws_acm_certificate_validation.dlx.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.backend_tg.arn
  }
} */