module nsg 'nsg.bicep' = {
  name: 'nsg-demo'
  params: {
    allowedOutboundAddresses: [
      '10.0.1.0/24'
      '10.0.2.0/24'
    ]
  }
}
