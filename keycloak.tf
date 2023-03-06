locals {

  keycloak = merge(
    {
      enabled                  = false
      version                  = "20.0.5"
      hostname                 = ""
      admin_hostname           = ""      
      tls_secret               = ""
    },
    var.keycloak
  )

}

resource "kubectl_manifest" "keycloak_deployment" {
  count   = local.keycloak.enabled ? 1 : 0
  yaml_body = <<-YAML
  apiVersion: k8s.keycloak.org/v2alpha1
  kind: Keycloak
  metadata:
    name: keycloak
  spec:
    instances: 1
    additionalOptions:
      - name: storage
        value: jpa
      - name: proxy
        value: none
    db:
      vendor: postgres
      host: cockroachdb
      database: keycloak
      port: 26257
      usernameSecret:
        name: keycloak-db-secret-1
        key: username
      passwordSecret:
        name: keycloak-db-secret-1
        key: password
    http:
      tlsSecret: ${local.keycloak.tls_secret}
    hostname:
      hostname: ${local.keycloak.hostname}
    ingress:
      enabled: true
  YAML

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}