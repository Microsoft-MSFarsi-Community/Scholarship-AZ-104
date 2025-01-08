param lb_name string = 'ld-name'
param fip_name string = 'fip-name'
param bk_name string = 'bk-name'
param healprob string = 'hlprob-name'
param location string = 'westeurope'
param sku string = 'Standard'
param tier string = 'Regional'
// param subnet_id string = 'id'
param rule_name string = 'rul-name'
param pip_name string = 'pip-webapp-prod-WestEU-01'
param vnetid string = 'id'
// param nic2 string = 'od'

// param vmnetid1 string =  '/subscriptions/33b7b305-44f2-4223-881d-46a8ebaa2e69/resourceGroups/sch-Mostafa-Mostafavinezhad-rg/providers/Microsoft.Network/networkInterfaces/vm-webapp-prod-WestEU-01-nic'
// param vmnetid2 string =  '/subscriptions/33b7b305-44f2-4223-881d-46a8ebaa2e69/resourceGroups/sch-Mostafa-Mostafavinezhad-rg/providers/Microsoft.Network/networkInterfaces/vm-webapp-prod-WestEU-02-nic'

resource pip 'Microsoft.Network/publicIpAddresses@2022-05-01' = {
  name: pip_name
  location: location
  tags: {}
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Standard'
    tier: tier
  }
}


resource load_balancer 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: lb_name
  location: location
  properties: {
    frontendIPConfigurations:[
      {
        name: fip_name
        properties: {
          publicIPAddress:{
            id: pip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: bk_name
      }
    ]
    outboundRules: [
      {
        name: 'SNAT'
        properties: {
          allocatedOutboundPorts: 31992
          protocol: 'All'
          enableTcpReset: true
          idleTimeoutInMinutes: 4
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',lb_name,bk_name)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations',lb_name,fip_name)
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: healprob
        properties: {
          protocol: 'TCP'
          port: 80
          requestPath: null
          intervalInSeconds: 5
          numberOfProbes: 1
        }
      }
    ]
    loadBalancingRules: [
      {
        name: rule_name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations',lb_name,fip_name)
          }
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'TCP'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes',lb_name,healprob)
          }
          disableOutboundSnat: true
          enableTcpReset: true
          backendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',lb_name,bk_name)
            }
          ]
        }
      }
    ]
  }
  sku:{
    name: sku
  }
}

output backpoolid string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools',lb_name,bk_name)
output frontpoolid string = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations',lb_name,fip_name)
