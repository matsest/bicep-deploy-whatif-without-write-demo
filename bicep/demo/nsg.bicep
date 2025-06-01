param baseName string = resourceGroup().name
param name string = '${baseName}-nsg'
param location string = resourceGroup().location
param allowedOutboundAddresses array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: name
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-outbound-demo'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Outbound'
          destinationAddressPrefixes: allowedOutboundAddresses
        }
      }
    ]
  }
}
