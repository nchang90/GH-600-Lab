// Subscription-scoped entry point, which is what `azd provision` expects.
// It creates the resource group, then delegates every resource to
// resources.bicep. `azd down` removes the whole group in one step.
targetScope = 'subscription'

@description('Name of the azd environment. Used in resource names and required for azd to track what it owns.')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Azure region for all resources.')
@minLength(1)
param location string

@description('CIDR range allowed to reach the cart API, for example 203.0.113.10/32.')
param allowedIpAddressRange string

@description('Container image for the cart API, published by .github/workflows/publish-image.yml. Example: ghcr.io/<owner>/gh-600-lab-cart:<sha>.')
param cartApiImage string

// The azd-env-name tag is how azd recognises resources belonging to this
// environment. Removing it will orphan the resource group from `azd down`.
var tags = {
  'azd-env-name': environmentName
  application: 'gh600lab-cart'
  managedBy: 'azd'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: resourceGroup
  params: {
    location: location
    allowedIpAddressRange: allowedIpAddressRange
    cartApiImage: cartApiImage
    tags: tags
  }
}

output AZURE_RESOURCE_GROUP string = resourceGroup.name
output AZURE_LOCATION string = location
output CART_API_URL string = resources.outputs.cartApiUrl
output CART_API_NAME string = resources.outputs.cartApiName
