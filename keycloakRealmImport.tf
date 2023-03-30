locals {

  keycloakRealmImport = merge(
    {
      enabled                     = false
      realmImportPath             = ""
      keycloak_hostname           = ""
      keycloak_dlx_uri            = ""
      keycloak_dlx_monitoring_uri = ""
      keycloak_backend_secret     = ""
      keycloak_admin_partyId      = ""
      keycloak_admin_password     = ""
      keycloak_loader_secret      = ""
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
  count     = local.keycloakRealmImport.enabled ? 1 : 0
  yaml_body = templatefile(local.keycloakRealmImport.realmImportPath, {
        keycloak_hostname           = local.keycloakRealmImport.keycloak_hostname
        keycloak_dlx_uri            = local.keycloakRealmImport.keycloak_dlx_uri
        keycloak_dlx_monitoring_uri = local.keycloakRealmImport.keycloak_dlx_monitoring_uri
        keycloak_backend_secret     = local.keycloakRealmImport.keycloak_backend_secret
        keycloak_admin_partyId      = local.keycloakRealmImport.keycloak_admin_partyId
        keycloak_admin_password     = local.keycloakRealmImport.keycloak_admin_password
        keycloak_loader_secret      = local.keycloakRealmImport.keycloak_loader_secret
      })

  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment,
    null_resource.wait_for_pod  
  ]
}