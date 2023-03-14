locals {

  cockroachdb = merge(
    {
      enabled                  = false
      version                  = "v22.1.2"
      resource_request_memory  = "2Gi"
      resource_limit_memory    = "4Gi"
      resource_request_cpu     = "500m"
      resource_limit_cpu       = "2"      
      node_size                = "3"
    },
    var.cockroachdb
  )

}


resource "kubectl_manifest" "cockroachdb_deployment" {
  count   = local.cockroachdb.enabled ? 1 : 0
  yaml_body = <<-YAML
  apiVersion: crdb.cockroachlabs.com/v1alpha1
  kind: CrdbCluster
  metadata:
    # this translates to the name of the statefulset that is created
    name: cockroachdb
  spec:
    # clientTLSSecret: cockroachdb.client.root
    # nodeTLSSecret: cockroachdb.node
    dataStore:
      pvc:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: "60Gi"
          volumeMode: Filesystem
    resources:
      requests:
        # This is intentionally low to make it work on local k3d clusters.
        cpu: ${local.cockroachdb.resource_request_cpu}
        memory: ${local.cockroachdb.resource_request_memory}
      limits:
        cpu: ${local.cockroachdb.resource_limit_cpu}
        memory: ${local.cockroachdb.resource_limit_memory}
    tlsEnabled: true
  # You can set either a version of the db or a specific image name
    cockroachDBVersion: ${local.cockroachdb.version}
    #image:
    #  name: cockroachdb/cockroach:${local.cockroachdb.version}
    # nodes refers to the number of crdb pods that are created
    # via the statefulset
    nodes: ${local.cockroachdb.node_size}
    additionalLabels:
      crdb: is-cool
    # affinity is a new API field that is behind a feature gate that is
    # disabled by default.  To enable please see the operator.yaml file.
  
    # The affinity field will accept any podSpec affinity rule.
    # affinity:
    #   podAntiAffinity:
    #      preferredDuringSchedulingIgnoredDuringExecution:
    #      - weight: 100
    #        podAffinityTerm:
    #          labelSelector:
    #            matchExpressions:
    #            - key: app.kubernetes.io/instance
    #              operator: In
    #              values:
    #              - cockroachdb
    #          topologyKey: kubernetes.io/hostname
  
    # nodeSelectors used to match against
    # nodeSelector:
    #   worker-pool-name: crdb-workers
  YAML

  depends_on = [
    kubectl_manifest.cockroach-operator
  ]
}


