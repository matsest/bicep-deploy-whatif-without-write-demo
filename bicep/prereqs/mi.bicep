@description('Required. The name of the Managed Identity.')
param name string
@description('Required. The location where the Managed Identity should be created. Defaults to the location of the resource group.')
param location string = resourceGroup().location

@description('The GitHub username that holds the repository the Managed Identity will be used with.')
param ghUserName string
@description('The GitHub repository name the Managed Identity will be used with.')
param ghRepoName string
@description('The GitHub environment name the Managed Identity will be used with.')
param ghEnvName string

@description('The Role definition ID used to assign to the Managed Identity. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for values')
param roleDefinitionId string

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: name
  location: location
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mi.id, roleDefinition.id, resourceGroup().id)
  properties: {
    principalId: mi.properties.principalId
    roleDefinitionId: roleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  name: ghRepoName
  parent: mi
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${ghUserName}/${ghRepoName}:environment:${ghEnvName}'
  }
}

output clientId string = mi.properties.clientId
