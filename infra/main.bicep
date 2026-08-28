targetScope = 'resourceGroup'

@description('Azure region for the Container Apps resources.')
param location string = resourceGroup().location

@description('Short environment name used in resource names and tags.')
@minLength(2)
@maxLength(12)
param environmentName string = 'dev'

@description('CIDR range allowed to reach the cart API, for example 203.0.113.10/32.')
param allowedIpAddressRange string

@description('Container image for the cart API, published by .github/workflows/publish-image.yml. Example: ghcr.io/<owner>/gh-600lab-cart:<sha>.')
param cartApiImage string

@description('Tags applied to the deployed resources.')
param tags object = {
  application: 'gh600lab-cart'
  environment: environmentName
  managedBy: 'bicep'
}

var uniqueSuffix = uniqueString(resourceGroup().id)
var managedEnvironmentName = 'cae-gh600lab-${environmentName}-${uniqueSuffix}'
var containerAppName = 'ca-cart-${environmentName}-${uniqueSuffix}'

module managedEnvironment 'br/public:avm/res/app/managed-environment:0.15.0' = {
  name: 'deploy-cart-environment'
  params: {
    name: managedEnvironmentName
    location: location
    // No Log Analytics workspace and no Azure Monitor destination. Log ingestion
    // is billed per GB and this lab reads logs through `az containerapp logs`
    // instead. Add a destination here when you need retained logs.
    publicNetworkAccess: 'Enabled'
    tags: tags
    zoneRedundant: false
  }
}

module cartApi 'br/public:avm/res/app/container-app:0.23.0' = {
  name: 'deploy-cart-api'
  params: {
    name: containerAppName
    location: location
    environmentResourceId: managedEnvironment.outputs.resourceId
    containers: [
      {
        name: 'cart-api'
        image: cartApiImage
        env: [
          {
            name: 'PORT'
            value: '8000'
          }
        ]
        probes: [
          {
            type: 'Readiness'
            httpGet: {
              path: '/healthz'
              port: 8000
              scheme: 'HTTP'
            }
            periodSeconds: 10
          }
          {
            type: 'Startup'
            failureThreshold: 30
            httpGet: {
              path: '/healthz'
              port: 8000
              scheme: 'HTTP'
            }
            periodSeconds: 1
            timeoutSeconds: 2
          }
        ]
        // Smallest valid CPU and memory pairing on the Consumption plan.
        resources: {
          cpu: json('0.25')
          memory: '0.5Gi'
        }
      }
    ]
    ingressAllowInsecure: false
    ingressExternal: true
    ingressTargetPort: 8000
    ingressTransport: 'auto'
    ipSecurityRestrictions: [
      {
        name: 'allowed-client'
        action: 'Allow'
        description: 'Limit the unauthenticated lab API to the reviewed client CIDR.'
        ipAddressRange: allowedIpAddressRange
      }
    ]
    // Scale to zero when idle. This is the difference between a few dollars a
    // month and effectively nothing: an app with no running replica is not
    // billed for compute. The cost is a cold start on the first request.
    scaleSettings: {
      minReplicas: 0
      maxReplicas: 1
    }
    tags: tags
  }
}

output cartApiName string = cartApi.outputs.name
output cartApiUrl string = 'https://${cartApi.outputs.fqdn}'
output managedEnvironmentName string = managedEnvironment.outputs.name
