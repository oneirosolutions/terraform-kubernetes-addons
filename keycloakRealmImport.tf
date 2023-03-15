locals {

  keycloakRealmImport = merge(
    {
      enabled                  = false
    },
    var.keycloakRealmImport
  )

}

resource "null_resource" "wait_for_pod" {
  provisioner "local-exec" {
    command = "kubectl wait pod/keycloak-0 --for=condition=Ready"
  }

  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment
  ]
}

resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count   = local.keycloakRealmImport.enabled ? 1 : 0
  force_new = true
  yaml_body = local.keycloakRealmImport.extra_values

  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment,
    null_resource.wait_for_pod
  ]
}