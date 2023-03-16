locals {

  keycloakRealmImport = merge(
    {
      enabled                  = false
//      keycloak_client_secret   = ""
      file_path                = "../../../../../../provider-config/eks-addons/keycloak/keycloakRealmImport.yaml"
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
data "local_file" "keycloakRealmImport_yaml" {
  filename = local.keycloakRealmImport.file_path
}
//data "template_file" "keycloakRealmImport_yaml" {
//  template = data.local_file.keycloakRealmImport_yaml.content
//  vars = {
//    keycloak_client_secret = local.keycloakRealmImport.keycloak_client_secret
//  }
//}
resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count   = local.keycloakRealmImport.enabled ? 1 : 0
  force_new = true
//  yaml_body = data.template_file.keycloakRealmImport_yaml.rendered
//  yaml_body = data.local_file.keycloakRealmImport_yaml.content
  yaml_body = local.keycloakRealmImport.extra_values

  depends_on = [
    kubectl_manifest.keycloak-operator,
    kubectl_manifest.keycloak_deployment,
    null_resource.wait_for_pod
  ]
}