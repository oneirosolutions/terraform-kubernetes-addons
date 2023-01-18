locals {

  jaeger = merge(
    {
      enabled                  = false
      instance_name            = "jaeger"
      namespace                = "test"
    },
    var.jaeger
  )

}


resource "kubectl_manifest" "jaeger_deployment" {
  count   = local.jaeger.enabled ? 1 : 0
  yaml_body = <<-YAML
  apiVersion: jaegertracing.io/v1
  kind: Jaeger
  metadata:
    # this translates to the name of the statefulset that is created
    name: ${local.jaeger.instance_name}
    namespace: ${local.jaeger.namespace}
  spec:
    ingress:
      enabled: false
  YAML

  depends_on = [
    kubectl_manifest.jaeger-operator
  ]
}


