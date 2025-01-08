param vnetName string = 'vnet_webapp_prod_WestEU_01'
param vnetAddressSpace string = '10.100.0.0/16'
param subnetName string = 'sbnet_webapp_prod_WestEU_01'
param subnetAddressSpace string = '10.100.10.0/24'

param subnetName2 string = 'sbnet_webapp_prod_WestEU_02'
param subnetAddressSpace2 string = '10.100.20.0/24'
param location string = 'westeurope'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        
        vnetAddressSpace
      ] 
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressSpace
        }
      }
      {
        name: subnetName2
        properties:{
          addressPrefix: subnetAddressSpace2
        }
      }
    ]
  }
}

output vnetId string = resourceId('Microsoft.Network/virtualNetworks',vnetName)
output subid1 string = resourceId('Microsoft.Network/virtualNetworks/subnets',vnetName,subnetName)
output subid2 string = resourceId('Microsoft.Network/virtualNetworks/subnets',vnetName,subnetName2)
