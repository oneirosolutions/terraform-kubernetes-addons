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

  keycloak-operator_apply = local.keycloak-operator["enabled"] ? flatten([for each_namespace in local.keycloak-operator.namespace : [
    for each_resource in data.kubectl_file_documents.keycloak-operator[0].documents : {
      namespace = each_namespace
      resource  = each_resource
    }
  ]
  ]) : null
}
data "http" "keycloak-operator-crd" {
  count = local.keycloak-operator.enabled ? length(local.keycloak-operator-crd_yaml_files) : 0
  url   = local.keycloak-operator-crd_yaml_files[count.index]
}
resource "kubectl_manifest" "keycloak-operator-crd" {
  count     = local.keycloak-operator.enabled ? length(data.http.keycloak-operator-crd) : 0
  yaml_body = data.http.keycloak-operator-crd[count.index].response_body
}
data "http" "keycloak-operator" {
  count = local.keycloak-operator.enabled ? 1 : 0
  url   = local.keycloak-operator_yaml
}
data "kubectl_file_documents" "keycloak-operator" {
  count = local.keycloak-operator.enabled ? 1 : 0
  content = data.http.keycloak-operator[0].response_body
}
resource "kubectl_manifest" "keycloak-operator" {
  count = local.keycloak-operator.enabled ? length(local.keycloak-operator_apply) : 0
  yaml_body = local.keycloak-operator_apply[count.index].resource
  override_namespace = local.keycloak-operator_apply[count.index].namespace

  depends_on = [
    kubectl_manifest.keycloak-operator-crd
  ]
}
#data "kubectl_file_documents" "keycloak-operator" {
#  count   = local.keycloak-operator.enabled ? 1 : 0
#  content = join("\n---\n", [for k, v in data.http.keycloak-operator : v.body])
#}
#resource "kubectl_manifest" "keycloak-operator" {
#  for_each  = local.keycloak-operator.enabled ? { for v in local.keycloak-operator_apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content } : {}
#  yaml_body = each.value
#}