locals {

  keycloak = merge(
    {
      enabled                  = false
      version                  = "v20.0.3"
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
    name: test-keycloak
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
      tlsSecret: example-tls-secret
      httpEnabled: true
      httpPort: 8180
      httpsPort: 8543
    hostname:
      hostname: localhost
    ingress:
      enabled: false
  YAML

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}
