locals {

  keycloak-operator = merge(
    {
      enabled = false
      version = "21.0.1"
      crd_version = "21.0.1"
      namespace = ["default"]
    },
    var.keycloak-operator
  )

  keycloak-operator-crd_yaml_files = [
    "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${local.keycloak-operator.crd_version}/kubernetes/keycloaks.k8s.keycloak.org-v1.yml",
    "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${local.keycloak-operator.crd_version}/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml",  
  ]

  keycloak-operator_yaml = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${local.keycloak-operator.version}/kubernetes/kubernetes.yml"

#  keycloak-operator_apply = local.keycloak-operator["enabled"] ? [for v in data.kubectl_file_documents.keycloak-operator[0].documents : {
#    data : yamldecode(v)
#    content : v
#    }
#  ] : null

}
data "http" "keycloak-operator-crd" {
  for_each = local.keycloak-operator.enabled ? toset(local.keycloak-operator-crd_yaml_files) : []
  url      = each.key
}
resource "kubectl_manifest" "keycloak-operator-crd" {
  for_each  = local.keycloak-operator.enabled ? data.http.keycloak-operator : []
  yaml_body = yamlencode(each.value)
}
data "http" "keycloak-operator" {
  count = local.keycloak-operator.enabled ? 1 : 0
  url   = local.keycloak-operator_yaml
}
resource "kubectl_manifest" "keycloak-operator" {
  for_each = local.keycloak-operator.enabled ? local.keycloak-operator.namespace : []
  yaml_body = yamlencode(data.http.keycloak-operator)
  override_namespace = each.key
}
#data "kubectl_file_documents" "keycloak-operator" {
#  count   = local.keycloak-operator.enabled ? 1 : 0
#  content = join("\n---\n", [for k, v in data.http.keycloak-operator : v.body])
#}
#resource "kubectl_manifest" "keycloak-operator" {
#  for_each  = local.keycloak-operator.enabled ? { for v in local.keycloak-operator_apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content } : {}
#  yaml_body = each.value
#}