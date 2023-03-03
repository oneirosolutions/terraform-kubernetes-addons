locals {

  keycloakRealmImport = merge(
    {
      enabled                  = false
      version                  = "20.0.5"
      realm_name               = "dev"
      roles                    = 
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
    name: keycloak-realm
  spec:
    keycloakCRName: keycloak
    realm: 
      realm: ${realm_name}
      displayName: ${realm_name}
      notBefore: 0
      defaultSignatureAlgorithm: RS256
      revokeRefreshToken: false
      refreshTokenMaxReuse: 0
      accessTokenLifespan: 300
      accessTokenLifespanForImplicitFlow: 900
      ssoSessionIdleTimeout: 1800
      ssoSessionMaxLifespan: 36000
      ssoSessionIdleTimeoutRememberMe: 0
      ssoSessionMaxLifespanRememberMe: 0
      offlineSessionIdleTimeout: 2592000
      offlineSessionMaxLifespanEnabled: false
      offlineSessionMaxLifespan: 5184000
      clientSessionIdleTimeout: 0
      clientSessionMaxLifespan: 0
      clientOfflineSessionIdleTimeout: 0
      clientOfflineSessionMaxLifespan: 0
      accessCodeLifespan: 60
      accessCodeLifespanUserAction: 300
      accessCodeLifespanLogin: 1800
      actionTokenGeneratedByAdminLifespan: 43200
      actionTokenGeneratedByUserLifespan: 300
      oauth2DeviceCodeLifespan: 600
      oauth2DevicePollingInterval: 5
      enabled: true
      sslRequired: external
      registrationAllowed: false
      registrationEmailAsUsername: false
      rememberMe: false
      verifyEmail: false
      loginWithEmailAllowed: true
      duplicateEmailsAllowed: false
      resetPasswordAllowed: false
      editUsernameAllowed: false
      bruteForceProtected: false
      permanentLockout: false
      maxFailureWaitSeconds: 900
      minimumQuickLoginWaitSeconds: 60
      waitIncrementSeconds: 60
      quickLoginCheckMilliSeconds: 1000
      maxDeltaTimeSeconds: 43200
      failureFactor: 30
      roles:
        ${roles}
      groups:
        ${groups}
      defaultRole:
        name: default-roles-dev
        description: "${role_default-roles}"
        composite: true
        clientRole: false
      requiredCredentials:
      - password
      otpPolicyType: totp
      otpPolicyAlgorithm: HmacSHA1
      otpPolicyInitialCounter: 0
      otpPolicyDigits: 6
      otpPolicyLookAheadWindow: 1
      otpPolicyPeriod: 30
      otpPolicyCodeReusable: false
      otpSupportedApplications:
      - totpAppGoogleName
      - totpAppFreeOTPName
      webAuthnPolicyRpEntityName: keycloak
      webAuthnPolicySignatureAlgorithms:
      - ES256
      webAuthnPolicyRpId: ''
      webAuthnPolicyAttestationConveyancePreference: not specified
      webAuthnPolicyAuthenticatorAttachment: not specified
      webAuthnPolicyRequireResidentKey: not specified
      webAuthnPolicyUserVerificationRequirement: not specified
      webAuthnPolicyCreateTimeout: 0
      webAuthnPolicyAvoidSameAuthenticatorRegister: false
      webAuthnPolicyAcceptableAaguids: []
      webAuthnPolicyPasswordlessRpEntityName: keycloak
      webAuthnPolicyPasswordlessSignatureAlgorithms:
      - ES256
      webAuthnPolicyPasswordlessRpId: ''
      webAuthnPolicyPasswordlessAttestationConveyancePreference: not specified
      webAuthnPolicyPasswordlessAuthenticatorAttachment: not specified
      webAuthnPolicyPasswordlessRequireResidentKey: not specified
      webAuthnPolicyPasswordlessUserVerificationRequirement: not specified
      webAuthnPolicyPasswordlessCreateTimeout: 0
      webAuthnPolicyPasswordlessAvoidSameAuthenticatorRegister: false
      webAuthnPolicyPasswordlessAcceptableAaguids: []
      scopeMappings:
      - clientScope: offline_access
        roles:
        - offline_access
      clientScopeMappings:
        account:
        - client: account-console
          roles:
          - manage-account
          - view-groups
      clients:
        ${clients}
      clientScopes:
        ${client_scopes}
      defaultDefaultClientScopes:
      - profile
      - email
      - roles
      - role_list
      - web-origins
      - acr
      defaultOptionalClientScopes:
      - microprofile-jwt
      - address
      - offline_access
      - phone
      browserSecurityHeaders:
        contentSecurityPolicyReportOnly: ''
        xContentTypeOptions: nosniff
        xRobotsTag: none
        xFrameOptions: SAMEORIGIN
        contentSecurityPolicy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';
        xXSSProtection: 1; mode=block
        strictTransportSecurity: max-age=31536000; includeSubDomains
      smtpServer: {}
      eventsEnabled: false
      eventsListeners:
      - jboss-logging
      enabledEventTypes: []
      adminEventsEnabled: false
      adminEventsDetailsEnabled: false
      identityProviders: []
      identityProviderMappers: []
      components:
        org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy:
        - id: 60a469ce-0623-43a5-b6b3-f97ad624ca91
          name: Max Clients Limit
          providerId: max-clients
          subType: anonymous
          subComponents: {}
          config:
            max-clients:
            - '200'
        - id: 1eaa1892-0add-4db7-a757-c27544cf492e
          name: Full Scope Disabled
          providerId: scope
          subType: anonymous
          subComponents: {}
          config: {}
        - id: eac067cc-c098-4a5f-ad69-409984a3272c
          name: Trusted Hosts
          providerId: trusted-hosts
          subType: anonymous
          subComponents: {}
          config:
            host-sending-registration-request-must-match:
            - 'true'
            client-uris-must-match:
            - 'true'
        - id: 29692521-0e19-4bd6-86e2-79d73b2055c5
          name: Allowed Client Scopes
          providerId: allowed-client-templates
          subType: authenticated
          subComponents: {}
          config:
            allow-default-scopes:
            - 'true'
        - id: 767bd6d1-0d03-4896-8e93-67fbec51d2b3
          name: Allowed Protocol Mapper Types
          providerId: allowed-protocol-mappers
          subType: authenticated
          subComponents: {}
          config:
            allowed-protocol-mapper-types:
            - saml-user-property-mapper
            - oidc-usermodel-attribute-mapper
            - oidc-address-mapper
            - oidc-usermodel-property-mapper
            - saml-role-list-mapper
            - saml-user-attribute-mapper
            - oidc-full-name-mapper
            - oidc-sha256-pairwise-sub-mapper
        - id: c2e8aeac-1b60-4237-a656-72ef8415bba5
          name: Consent Required
          providerId: consent-required
          subType: anonymous
          subComponents: {}
          config: {}
        - id: e4cdf700-0713-4746-8fd6-9328c7e84de6
          name: Allowed Protocol Mapper Types
          providerId: allowed-protocol-mappers
          subType: anonymous
          subComponents: {}
          config:
            allowed-protocol-mapper-types:
            - oidc-usermodel-property-mapper
            - saml-user-property-mapper
            - oidc-sha256-pairwise-sub-mapper
            - oidc-usermodel-attribute-mapper
            - oidc-address-mapper
            - oidc-full-name-mapper
            - saml-role-list-mapper
            - saml-user-attribute-mapper
        - id: 37c2b693-fc82-4f8e-90e6-f6d568d5cacd
          name: Allowed Client Scopes
          providerId: allowed-client-templates
          subType: anonymous
          subComponents: {}
          config:
            allow-default-scopes:
            - 'true'
        org.keycloak.keys.KeyProvider:
        - id: 519c3986-5e33-4cca-bddd-ca6413c76d00
          name: rsa-generated
          providerId: rsa-generated
          subComponents: {}
          config:
            priority:
            - '100'
        - id: a49bbf41-1ff5-45c0-9360-e4463b5b4cc2
          name: hmac-generated
          providerId: hmac-generated
          subComponents: {}
          config:
            priority:
            - '100'
            algorithm:
            - HS256
        - id: ac65044f-7486-4687-b26c-b1fd78764e2f
          name: aes-generated
          providerId: aes-generated
          subComponents: {}
          config:
            priority:
            - '100'
        - id: 503a4c03-e260-4681-85de-abd5d75b03ca
          name: rsa-enc-generated
          providerId: rsa-enc-generated
          subComponents: {}
          config:
            priority:
            - '100'
            algorithm:
            - RSA-OAEP
      internationalizationEnabled: false
      supportedLocales: []
      authenticationFlows:
      - id: 4d569986-0bef-4e6b-81df-b01d547cb904
        alias: Account verification options
        description: Method with which to verity the existing account
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: idp-email-verification
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: ALTERNATIVE
          priority: 20
          autheticatorFlow: true
          flowAlias: Verify Existing Account by Re-authentication
          userSetupAllowed: false
      - id: a93c4dd6-cd80-4b1c-9a8b-eb50a4955324
        alias: Authentication Options
        description: Authentication options.
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: basic-auth
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: basic-auth-otp
          authenticatorFlow: false
          requirement: DISABLED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: auth-spnego
          authenticatorFlow: false
          requirement: DISABLED
          priority: 30
          autheticatorFlow: false
          userSetupAllowed: false
      - id: f2a9edfa-c067-40c4-a9f6-ada42e726e75
        alias: Browser - Conditional OTP
        description: Flow to determine if the OTP is required for the authentication
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: conditional-user-configured
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: auth-otp-form
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
      - id: 00604d0a-a402-4432-95db-f529775330fc
        alias: Direct Grant - Conditional OTP
        description: Flow to determine if the OTP is required for the authentication
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: conditional-user-configured
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: direct-grant-validate-otp
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
      - id: dba95ab7-222a-43de-b049-ec875b754f24
        alias: First broker login - Conditional OTP
        description: Flow to determine if the OTP is required for the authentication
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: conditional-user-configured
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: auth-otp-form
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
      - id: ba0b9724-dcf2-4edd-b4f5-40e35db8eadc
        alias: Handle Existing Account
        description: Handle what to do if there is existing account with same email/username
          like authenticated identity provider
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: idp-confirm-link
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: true
          flowAlias: Account verification options
          userSetupAllowed: false
      - id: 84f99e3f-6ab8-4a35-ad9b-a8644377c2fb
        alias: Reset - Conditional OTP
        description: Flow to determine if the OTP should be reset or not. Set to REQUIRED
          to force.
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: conditional-user-configured
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: reset-otp
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
      - id: 041744e3-946f-400a-9bd1-98d7adeb93bb
        alias: User creation or linking
        description: Flow for the existing/non-existing user alternatives
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticatorConfig: create unique user config
          authenticator: idp-create-user-if-unique
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: ALTERNATIVE
          priority: 20
          autheticatorFlow: true
          flowAlias: Handle Existing Account
          userSetupAllowed: false
      - id: a17472df-40b5-41aa-ad6d-02a89186283b
        alias: Verify Existing Account by Re-authentication
        description: Reauthentication of existing account
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: idp-username-password-form
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: CONDITIONAL
          priority: 20
          autheticatorFlow: true
          flowAlias: First broker login - Conditional OTP
          userSetupAllowed: false
      - id: 9db24ca2-733c-43c2-a8ac-1796eeb79fb3
        alias: browser
        description: browser based authentication
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: auth-cookie
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: auth-spnego
          authenticatorFlow: false
          requirement: DISABLED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: identity-provider-redirector
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 25
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: ALTERNATIVE
          priority: 30
          autheticatorFlow: true
          flowAlias: forms
          userSetupAllowed: false
      - id: 56dde35d-6b33-48d1-9af1-e3741f6dc5bd
        alias: clients
        description: Base authentication for clients
        providerId: client-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: client-secret
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: client-jwt
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: client-secret-jwt
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 30
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: client-x509
          authenticatorFlow: false
          requirement: ALTERNATIVE
          priority: 40
          autheticatorFlow: false
          userSetupAllowed: false
      - id: 30ce0f18-9f8a-4d80-8415-c92db797089c
        alias: direct grant
        description: OpenID Connect Resource Owner Grant
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: direct-grant-validate-username
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: direct-grant-validate-password
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: CONDITIONAL
          priority: 30
          autheticatorFlow: true
          flowAlias: Direct Grant - Conditional OTP
          userSetupAllowed: false
      - id: c34369e8-cc94-4be7-824c-239b00dcbdc0
        alias: docker auth
        description: Used by Docker clients to authenticate against the IDP
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: docker-http-basic-authenticator
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
      - id: dfbbecba-9087-4ad2-a08c-6493b7328d10
        alias: first broker login
        description: Actions taken after first broker login with identity provider account,
          which is not yet linked to any Keycloak account
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticatorConfig: review profile config
          authenticator: idp-review-profile
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: true
          flowAlias: User creation or linking
          userSetupAllowed: false
      - id: efb90e53-b464-4184-893b-31d1028af85f
        alias: forms
        description: Username, password, otp and other auth forms.
        providerId: basic-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: auth-username-password-form
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: CONDITIONAL
          priority: 20
          autheticatorFlow: true
          flowAlias: Browser - Conditional OTP
          userSetupAllowed: false
      - id: 625562dd-96d9-4c6b-acd1-1e3ddfcc9e9d
        alias: http challenge
        description: An authentication flow based on challenge-response HTTP Authentication
          Schemes
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: no-cookie-redirect
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: true
          flowAlias: Authentication Options
          userSetupAllowed: false
      - id: 6392ed02-01ab-4b86-85da-43768ed26ce8
        alias: registration
        description: registration flow
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: registration-page-form
          authenticatorFlow: true
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: true
          flowAlias: registration form
          userSetupAllowed: false
      - id: b37c992a-1c7b-4e9d-a64d-a3fd9b65fa49
        alias: registration form
        description: registration form
        providerId: form-flow
        topLevel: false
        builtIn: true
        authenticationExecutions:
        - authenticator: registration-user-creation
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: registration-profile-action
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 40
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: registration-password-action
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 50
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: registration-recaptcha-action
          authenticatorFlow: false
          requirement: DISABLED
          priority: 60
          autheticatorFlow: false
          userSetupAllowed: false
      - id: 8ffaa250-9be4-4d9d-9638-a715420de0c6
        alias: reset credentials
        description: Reset credentials for a user if they forgot their password or something
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: reset-credentials-choose-user
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: reset-credential-email
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 20
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticator: reset-password
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 30
          autheticatorFlow: false
          userSetupAllowed: false
        - authenticatorFlow: true
          requirement: CONDITIONAL
          priority: 40
          autheticatorFlow: true
          flowAlias: Reset - Conditional OTP
          userSetupAllowed: false
      - id: 13f7666a-c855-4509-81aa-6bbe9c3141ad
        alias: saml ecp
        description: SAML ECP Profile Authentication Flow
        providerId: basic-flow
        topLevel: true
        builtIn: true
        authenticationExecutions:
        - authenticator: http-basic-authenticator
          authenticatorFlow: false
          requirement: REQUIRED
          priority: 10
          autheticatorFlow: false
          userSetupAllowed: false
      authenticatorConfig:
      - id: 31bd980e-9e6e-459b-9712-c7d122038b31
        alias: create unique user config
        config:
          require.password.update.after.registration: 'false'
      - id: 9c32eaf4-4be8-43f8-8ef9-9a5f5445fffc
        alias: review profile config
        config:
          update.profile.on.first.login: missing
      requiredActions:
      - alias: CONFIGURE_TOTP
        name: Configure OTP
        providerId: CONFIGURE_TOTP
        enabled: true
        defaultAction: false
        priority: 10
        config: {}
      - alias: terms_and_conditions
        name: Terms and Conditions
        providerId: terms_and_conditions
        enabled: false
        defaultAction: false
        priority: 20
        config: {}
      - alias: UPDATE_PASSWORD
        name: Update Password
        providerId: UPDATE_PASSWORD
        enabled: true
        defaultAction: false
        priority: 30
        config: {}
      - alias: UPDATE_PROFILE
        name: Update Profile
        providerId: UPDATE_PROFILE
        enabled: true
        defaultAction: false
        priority: 40
        config: {}
      - alias: VERIFY_EMAIL
        name: Verify Email
        providerId: VERIFY_EMAIL
        enabled: true
        defaultAction: false
        priority: 50
        config: {}
      - alias: delete_account
        name: Delete Account
        providerId: delete_account
        enabled: false
        defaultAction: false
        priority: 60
        config: {}
      - alias: webauthn-register
        name: Webauthn Register
        providerId: webauthn-register
        enabled: true
        defaultAction: false
        priority: 70
        config: {}
      - alias: webauthn-register-passwordless
        name: Webauthn Register Passwordless
        providerId: webauthn-register-passwordless
        enabled: true
        defaultAction: false
        priority: 80
        config: {}
      - alias: update_user_locale
        name: Update User Locale
        providerId: update_user_locale
        enabled: true
        defaultAction: false
        priority: 1000
        config: {}
      browserFlow: browser
      registrationFlow: registration
      directGrantFlow: direct grant
      resetCredentialsFlow: reset credentials
      clientAuthenticationFlow: clients
      dockerAuthenticationFlow: docker auth
      attributes:
        cibaBackchannelTokenDeliveryMode: poll
        cibaExpiresIn: '120'
        cibaAuthRequestedUserHint: login_hint
        oauth2DeviceCodeLifespan: '600'
        clientOfflineSessionMaxLifespan: '0'
        oauth2DevicePollingInterval: '5'
        clientSessionIdleTimeout: '0'
        parRequestUriLifespan: '60'
        clientSessionMaxLifespan: '0'
        clientOfflineSessionIdleTimeout: '0'
        cibaInterval: '5'
        realmReusableOtpCode: 'false'
      keycloakVersion: ${version}
      userManagedAccessAllowed: false
      clientProfiles:
        profiles: []
      clientPolicies:
        policies: []
  YAML

  depends_on = [
    kubectl_manifest.keycloak-operator
  ]
}