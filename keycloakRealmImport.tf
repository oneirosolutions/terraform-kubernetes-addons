locals {

  keycloakRealmImport = merge(
    {
      enabled                  = false
      version                  = "20.0.5"
    },
    var.keycloakRealmImport
  )

}

resource "kubectl_manifest" "keycloakRealmImport_deployment" {
  count   = local.keycloakRealmImport.enabled ? 1 : 0
  yaml_body = <<-YAML
  apiVersion: k8s.keycloak.org/v2alpha1
  kind: KeycloakRealmImport
  metadata:
    name: test-keycloak-realm
  spec:
    keycloakCRName: test-keycloak
    realm: 
      id: dev
      realm: dev
      displayName: dev
      enabled: true
      groups:
        - name: admin
          id: admin
          realmRoles: [
            dlx:acknowledge:messages,
            dlx:acknowledge:notifications,
            dlx:checker2:tasks,
            dlx:checker:tasks,
            dlx:create:activities,
            dlx:create:messages,
            dlx:create:parties,
            dlx:delete:documents,
            dlx:delete:transactions,
            dlx:download:documents,
            dlx:generate:notices,
            dlx:load:factors,
            dlx:maker:tasks,
            dlx:mutate:transactions,
            dlx:project:transactions,
            dlx:read:activities,
            dlx:read:businessDays,
            dlx:read:calendars,
            dlx:read:charts,
            dlx:read:documents,
            dlx:read:events,
            dlx:read:factors,
            dlx:read:messages,
            dlx:read:notifications,
            dlx:read:parties,
            dlx:read:schedules,
            dlx:read:settlementInstructions,
            dlx:read:simulations,
            dlx:read:transactions,
            dlx:releaseFunds:tasks,
            dlx:update:activities,
            dlx:update:parties,
            dlx:update:settings,
            dlx:upload:documents
          ]
        - name: admin_customer
          id: admin_customer
          realmRoles: [
            dlx:acknowledge:messages,
            dlx:acknowledge:notifications,
            dlx:checker2:tasks,
            dlx:checker:tasks,
            dlx:create:activities,
            dlx:create:messages,
            dlx:create:parties,
            dlx:delete:documents,
            dlx:delete:transactions,
            dlx:download:documents,
            dlx:generate:notices,
            dlx:load:factors,
            dlx:maker:tasks,
            dlx:mutate:transactions,
            dlx:project:transactions,
            dlx:read:activities,
            dlx:read:businessDays,
            dlx:read:calendars,
            dlx:read:charts,
            dlx:read:documents,
            dlx:read:events,
            dlx:read:factors,
            dlx:read:messages,
            dlx:read:notifications,
            dlx:read:parties,
            dlx:read:schedules,
            dlx:read:settlementInstructions,
            dlx:read:simulations,
            dlx:read:transactions,
            dlx:releaseFunds:tasks,
            dlx:update:activities,
            dlx:update:parties,
            dlx:upload:documents
          ]
        - name: approver1
          id: approver1
          realmRoles: [
            dlx:acknowledge:messages,
            dlx:acknowledge:notifications,
            dlx:checker2:tasks,
            dlx:create:activities,
            dlx:create:messages,
            dlx:create:parties,
            dlx:delete:documents,
            dlx:delete:transactions,
            dlx:download:documents,
            dlx:generate:notices,
            dlx:load:factors,
            dlx:maker:tasks,
            dlx:mutate:transactions,
            dlx:project:transactions,
            dlx:read:activities,
            dlx:read:businessDays,
            dlx:read:calendars,
            dlx:read:charts,
            dlx:read:documents,
            dlx:read:events,
            dlx:read:factors,
            dlx:read:messages,
            dlx:read:notifications,
            dlx:read:parties,
            dlx:read:schedules,
            dlx:read:settlementInstructions,
            dlx:read:simulations,
            dlx:read:transactions,
            dlx:releaseFunds:tasks,
            dlx:update:activities,
            dlx:update:parties,
            dlx:upload:documents
          ]
        - name: approver2
          id: approver2
          realmRoles: [
            dlx:acknowledge:messages,
            dlx:acknowledge:notifications,
            dlx:checker2:tasks,
            dlx:checker:tasks,
            dlx:create:activities,
            dlx:create:messages,
            dlx:create:parties,
            dlx:delete:documents,
            dlx:delete:transactions,
            dlx:download:documents,
            dlx:generate:notices,
            dlx:load:factors,
            dlx:maker:tasks,
            dlx:mutate:transactions,
            dlx:project:transactions,
            dlx:read:activities,
            dlx:read:businessDays,
            dlx:read:calendars,
            dlx:read:charts,
            dlx:read:documents,
            dlx:read:events,
            dlx:read:factors,
            dlx:read:messages,
            dlx:read:notifications,
            dlx:read:parties,
            dlx:read:schedules,
            dlx:read:settlementInstructions,
            dlx:read:simulations,
            dlx:read:transactions,
            dlx:releaseFunds:tasks,
            dlx:update:activities,
            dlx:update:parties,
            dlx:upload:documents
          ]
        - name: ops
          id: ops
          realmRoles: [
            dlx:acknowledge:messages,
            dlx:acknowledge:notifications,
            dlx:checker2:tasks,
            dlx:checker:tasks,
            dlx:create:activities,
            dlx:create:messages,
            dlx:create:parties,
            dlx:delete:documents,
            dlx:delete:transactions,
            dlx:download:documents,
            dlx:generate:notices,
            dlx:load:factors,
            dlx:maker:tasks,
            dlx:mutate:transactions,
            dlx:project:transactions,
            dlx:read:activities,
            dlx:read:businessDays,
            dlx:read:calendars,
            dlx:read:charts,
            dlx:read:documents,
            dlx:read:events,
            dlx:read:factors,
            dlx:read:messages,
            dlx:read:notifications,
            dlx:read:parties,
            dlx:read:schedules,
            dlx:read:settlementInstructions,
            dlx:read:simulations,
            dlx:read:transactions,
            dlx:releaseFunds:tasks,
            dlx:update:activities,
            dlx:update:parties,
            dlx:update:settings,
            dlx:upload:documents
          ]
      roles:
        realm: 
          - name: dlx:read:transactions
            description: Query Transactions
          - name: dlx:mutate:transactions
            description: Create, Update, Close Transactions
          - name: dlx:project:transactions
            description: Simulate/Project Transactions
          - name: dlx:read:events
            description: Query Transaction Events
          - name: dlx:read:documents
            description: Reads Data Room Documents
          - name: dlx:download:documents
            description: Download Documents in Data Room
          - name: dlx:upload:documents
            description: Upload Documents in Data Room
          - name: dlx:delete:documents
            description: Delete Documents in Data Room
          - name: dlx:read:charts
            description: Access to Dashboard Charts
          - name: dlx:read:calendars
            description: Read Calendars
          - name: dlx:read:factors
            description: Query Factors and Their History
          - name: dlx:read:activities
            description: Query Activities
          - name: dlx:update:activities
            description: Update Activities
          - name: dlx:create:activities
            description: Create New Activities
          - name: dlx:read:notifications
            description: Read Notifications
          - name: dlx:acknowledge:notifications
            description: Acknowledge Notifications
          - name: dlx:create:messages
            description: Create Chat Messages
          - name: dlx:read:messages
            description: Query Chat Messages
          - name: dlx:acknowledge:messages
            description: Acknowledge Chat Messages
          - name: dlx:load:factors
            description: Load Factors in System
          - name: dlx:read:businessDays
            description: Query Business Days
          - name: dlx:create:parties
            description: Create New Parties
          - name: dlx:update:parties
            description: Update Parties
          - name: dlx:read:parties
            description: Query Parties Information
          - name: dlx:read:settlementInstructions
            description: Query Settlement Instructions Attached to a Party
          - name: dlx:read:simulations
            description: Access to Simulations
          - name: dlx:checker:tasks
            description: Approver Tasks
          - name: dlx:maker:tasks
            description: Maker of Tasks
          - name: dlx:delete:transactions
            description: Delete Transactions
          - name: dlx:update:settings
            description: DLX Update Settings
          - name: dlx:generate:notices
            description: Generate Notices
          - name: dlx:checker2:tasks
            description: DLX Checker 2 Tasks
          - name: dlx:releaseFunds:tasks
            description: Release Funds Task Permission
          - name: dlx:read:schedules
            description: Read Schedules
  YAML

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}