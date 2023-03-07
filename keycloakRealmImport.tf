locals {

  keycloakRealmImport = merge(
    {
      enabled                  = false
    },
    var.keycloakRealmImport
  )

}

resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count   = local.keycloakRealmImport.enabled ? 1 : 0
  yaml_body = local.keycloakRealmImport.extra_values

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}