locals {

  keycloak = merge(
    {
      enabled                  = false
      version                  = "20.0.5"
      tls_secret               = "example-tls-secret"
      hostname                 = "localhost"
      ingress_enabled          = false
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
      - name: hostname-strict-https
        value: "false"
      - name: proxy
        value: none
      - name: hostname-port
        value: "8543"
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
      httpEnabled: true
      httpPort: 8180
      httpsPort: 8543
    hostname:
      hostname: ${local.keycloak.hostname}
      admin: admin.keycloak.oneirosolutions.com
    ingress:
      enabled: true
  YAML

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}