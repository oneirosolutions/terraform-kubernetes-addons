locals {

  cockroach-operator = merge(
    {
      enabled = false
      version = "v2.8.0"
      crd_version = "v2.8.0"
    },
    var.cockroach-operator
  )

  cockroach-operator_yaml_files = [
    "https://raw.githubusercontent.com/cockroachdb/cockroach-operator/${local.cockroach-operator.crd_version}/install/crds.yaml",
    "https://raw.githubusercontent.com/cockroachdb/cockroach-operator/${local.cockroach-operator.version}/install/operator.yaml"
  ]

  cockroach-operator_apply = local.cockroach-operator["enabled"] ? [for v in data.kubectl_file_documents.cockroach-operator[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ] : null

}

data "http" "cockroach-operator" {
  for_each = local.cockroach-operator.enabled ? toset(local.cockroach-operator_yaml_files) : []
  url      = each.key
}

data "kubectl_file_documents" "cockroach-operator" {
  count   = local.cockroach-operator.enabled ? 1 : 0
  content = join("\n---\n", [for k, v in data.http.cockroach-operator : v.body])
}

resource "kubectl_manifest" "cockroach-operator" {
  for_each  = local.cockroach-operator.enabled ? { for v in local.cockroach-operator_apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content } : {}
  yaml_body = each.value
}
