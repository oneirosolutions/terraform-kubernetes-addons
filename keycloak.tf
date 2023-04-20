locals {

  keycloak = merge(
    {
      enabled                  = false
      keycloak_hostname        = ""
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
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment
  ]
}