locals {

  keycloakRealmImport = merge(
    {
      enabled                      = false
      keycloak_realm_name          = [""]
      keycloak_dlx_uri             = [""]
      keycloak_dlx_backend_uri     = [""]
      keycloak_admin_partyId       = [""]
      keycloak_admin_password      = ""
      keycloak_smtp_user           = ""
      keycloak_smtp_password       = ""
      keycloak_smtp_email_address  = ""
      keycloak_smtp_host           = ""
      keycloak_backend_secret_name = [""]
      keycloak_loader_secret_name  = [""]
      keycloak_version             = ""
    },
    var.keycloakRealmImport
  )

}
data "aws_secretsmanager_secret_version" "backend" {
  count     = local.keycloakRealmImport.enabled ? length(local.keycloakRealmImport.keycloak_backend_secret_name) : 0
  secret_id = local.keycloakRealmImport.keycloak_backend_secret_name
}
data "aws_secretsmanager_secret_version" "loader" {
  count     = local.keycloakRealmImport.enabled ? length(local.keycloakRealmImport.keycloak_loader_secret_name) : 0
  secret_id = local.keycloakRealmImport.keycloak_loader_secret_name
}
resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count     = local.keycloakRealmImport.enabled ? length(local.keycloakRealmImport.keycloak_realm_name) : 0
  yaml_body = templatefile(
    "${path.cwd}/../../../../../../../../../../../provider-config/eks-addons/keycloak/realmImport.yaml",
    {
      keycloak_realm_name         = local.keycloakRealmImport.keycloak_realm_name[count.index]
      keycloak_dlx_uri            = local.keycloakRealmImport.keycloak_dlx_uri[count.index]
      keycloak_dlx_backend_uri    = local.keycloakRealmImport.keycloak_dlx_backend_uri[count.index]
      keycloak_admin_partyId      = local.keycloakRealmImport.keycloak_admin_partyId[count.index]
      keycloak_admin_password     = local.keycloakRealmImport.keycloak_admin_password
      keycloak_smtp_user          = local.keycloakRealmImport.keycloak_smtp_user
      keycloak_smtp_password      = local.keycloakRealmImport.keycloak_smtp_password
      keycloak_smtp_email_address = local.keycloakRealmImport.keycloak_smtp_email_address
      keycloak_smtp_host          = local.keycloakRealmImport.keycloak_smtp_host
      keycloak_backend_secret     = jsondecode(data.aws_secretsmanager_secret_version.backend[count.index].secret_string)["KC_USER_CLIENTSECRET"]
      keycloak_loader_secret      = jsondecode(data.aws_secretsmanager_secret_version.loader[count.index].secret_string)["KC_CLIENTSECRET"]
      keycloak_version            = local.keycloakRealmImport.keycloak_version
    }
  )
  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment,
  ]
}