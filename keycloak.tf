locals {

  keycloak = merge(
    {
      enabled                  = false
    },
    var.keycloak
  )

}

resource "kubectl_manifest" "keycloak_deployment" {
  count  = local.keycloak.enabled ? 1 : 0
  yaml_body = local.keycloak.extra_values

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}