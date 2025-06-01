targetScope = 'subscription'

@description('The baseName used for resource group and managed dentity names.')
param baseName string = 'demo-whatif-gh'
@description('The location used for resource group and managed identity.')
param location string = 'norwayeast'

@description('The Role definition ID used to assign to the Managed Identity. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for values. The default is the Contributor role.')
param deployerRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('The Role definition ID used to assign to the Managed Identity. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for values. The default is the Reader role.')
param prRoleDefinitionId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

@description('The GitHub username that holds the repository the Managed Identity will be used with.')
param ghUserName string
@description('The GitHub repository name the Managed Identity will be used with.')
param ghRepoName string = 'bicep-deploy-whatif-without-write-demo'

@description('The GitHub environment name the Deployer Managed Identity will be used with.')
param ghMainEnvName string = 'Azure'

@description('The GitHub environment name the PR Managed Identity will be used with.')
param ghPREnvName string = 'Azure-PR'

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${baseName}-rg'
  location: location
}

module deployerIdentity 'mi.bicep' = {
  scope: rg
  name: 'deployer-mi-demo'
  params: {
    name: '${baseName}-main-uaid'
    location: location
    ghUserName: ghUserName
    ghRepoName: ghRepoName
    ghEnvName: ghMainEnvName
    roleDefinitionId: deployerRoleDefinitionId
  }
}

module prIdentity 'mi.bicep' = {
  scope: rg
  name: 'reader-mi-demo'
  params: {
    name: '${baseName}-pr-uaid'
    location: location
    ghUserName: ghUserName
    ghRepoName: ghRepoName
    ghEnvName: ghPREnvName
    roleDefinitionId: prRoleDefinitionId
  }
}

output subscriptionId string = subscription().subscriptionId
output tenantId string = subscription().tenantId

output deployerClientId string = deployerIdentity.outputs.clientId

output prClientId string = prIdentity.outputs.clientId
