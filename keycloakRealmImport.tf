locals {

  keycloakRealmImport = merge(
    {
      enabled                      = false
      keycloak_realm_name          = ""
      keycloak_hostname            = ""
      keycloak_dlx_uri             = ""
      keycloak_dlx_monitoring_uri  = ""
      keycloak_admin_partyId       = ""
      keycloak_admin_password      = ""
      keycloak_backend_secret_name = ""
      keycloak_loader_secret_name  = ""
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
data "aws_secretsmanager_secret_version" "backend" {
  count     = local.keycloakRealmImport.enabled ? 1 : 0
  secret_id = local.keycloakRealmImport.keycloak_backend_secret_name
}
data "aws_secretsmanager_secret_version" "loader" {
  count     = local.keycloakRealmImport.enabled ? 1 : 0
  secret_id = local.keycloakRealmImport.keycloak_loader_secret_name
}
resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count     = local.keycloakRealmImport.enabled ? 1 : 0
  yaml_body = templatefile(
    "${path.cwd}/../../../../../../../../../../../provider-config/eks-addons/keycloak/realmImport.yaml",
    {
      keycloak_hostname           = local.keycloakRealmImport.keycloak_hostname
      keycloak_realm_name         = local.keycloakRealmImport.keycloak_realm_name
      keycloak_dlx_uri            = local.keycloakRealmImport.keycloak_dlx_uri
      keycloak_dlx_monitoring_uri = local.keycloakRealmImport.keycloak_dlx_monitoring_uri
      keycloak_backend_secret     = jsondecode(data.aws_secretsmanager_secret_version.backend[count.index].secret_string)["KC_USER_CLIENTSECRET"]
      keycloak_admin_partyId      = local.keycloakRealmImport.keycloak_admin_partyId
      keycloak_admin_password     = local.keycloakRealmImport.keycloak_admin_password
      keycloak_loader_secret      = jsondecode(data.aws_secretsmanager_secret_version.loader[count.index].secret_string)["KC_CLIENTSECRET"]
    }
  )
  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment,
    null_resource.wait_for_pod
  ]
}