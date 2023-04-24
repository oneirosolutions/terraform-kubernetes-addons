locals {

  keycloak = merge(
    {
      enabled                  = false
      keycloak_hostname        = ""
      eks_cluster_name         = ""
    },
    var.keycloak
  )

}
resource "kubectl_manifest" "keycloak_deployment" {
  count     = local.keycloak.enabled ? 1 : 0
  yaml_body = templatefile(
    "${path.cwd}/../../../../../../../../../../../provider-config/eks-addons/keycloak/keycloak.yaml",
    {
      keycloak_hostname = local.keycloak.keycloak_hostname
    }
  )
  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}
resource "kubectl_manifest" "keycloak_ingress" {
  count     = local.keycloak.enabled ? 1 : 0
  yaml_body = templatefile(
    "${path.cwd}/../../../../../../../../../../../provider-config/eks-addons/keycloak/keycloak-ingress.yaml",
    {
      keycloak_hostname = local.keycloak.keycloak_hostname
    }
  )
  force_new = true
  depends_on = [
    kubectl_manifest.keycloak_deployment
  ]
}
data "aws_lb" "cluster_elb" {
  tags = {
    "service.k8s.aws/resource" = "LoadBalancer"
    "service.k8s.aws/stack" = "ingress-nginx/ingress-nginx-controller"
    "elbv2.k8s.aws/cluster" = "op-eks-stage-ireland"
  }
}
resource "aws_route53_record" "keycloak_dns" {
  count   = local.keycloak.enabled ? 1 : 0
  zone_id = "Z05857706UHYGSK0Q7ZS"
  name    = "kc.stage.ireland"
  type    = "A"
  alias {
    name                   = data.aws_lb.cluster_elb.dns_name
    zone_id                = data.aws_lb.cluster_elb.zone_id
    evaluate_target_health = true
  }
  depends_on = [
    kubectl_manifest.keycloak_ingress
  ]
}