locals {

  jaeger-operator = merge(
    {
      enabled = false
      version = "v1.41.0"
      crd_version = "v1.41.0"
      namespace   = "observability"
    },
    var.jaeger-operator
  )

  jaeger-operator_yaml_files = [
    "https://github.com/jaegertracing/jaeger-operator/releases/download/${local.jaeger-operator.crd_version}/jaeger-operator.yaml"
  ]

  jaeger-operator_apply = local.jaeger-operator["enabled"] ? [for v in data.kubectl_file_documents.jaeger-operator[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ] : null

}

resource "kubernetes_namespace" "observability" {
  count = local.jaeger-operator["enabled"] ? 1 : 0

  metadata {

    labels = {
      name = local.jaeger-operator["namespace"]
    }

    name = local.jaeger-operator["namespace"]
  }
}


data "http" "jaeger-operator" {
  for_each = local.jaeger-operator.enabled ? toset(local.jaeger-operator_yaml_files) : []
  url      = each.key
}

data "kubectl_file_documents" "jaeger-operator" {
  count   = local.jaeger-operator.enabled ? 1 : 0
  content = join("\n---\n", [for k, v in data.http.jaeger-operator : v.body])
}

resource "kubectl_manifest" "jaeger-operator" {
  for_each  = local.jaeger-operator.enabled ? { for v in local.jaeger-operator_apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace",local.jaeger-operator["namespace"]), v.data.metadata.name]))) => v.content } : {}
  yaml_body = each.value
}
