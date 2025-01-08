param location string = 'westeurope'

param virtualMachineName string = 'vm-webapp-prod-WestEU-01'
param networkInterfaceName string = '${virtualMachineName}-nic'
param networkSecurityGroupName string = '${virtualMachineName}-nsg'
param subnetName string = 'sbnet_webapp_prod_WestEU_01_name'

param virtualNetworkId string =  '/subscriptions/33b7b305-44f2-4223-881d-46a8ebaa2e69/resourceGroups/sch-Mostafa-Mostafavinezhad-rg/providers/Microsoft.Network/virtualNetworks/vnet_webapp_prod_WestEU_01_name'
param virtualMachineComputerName string = virtualMachineName
param osDiskType string = 'Premium_LRS'
param osDiskDeleteOption string = 'Delete'
param virtualMachineSize string = 'Standard_DS1_v2'
param nicDeleteOption string ='Delete'
param adminUsername string = 'adminuser'
param adminPassword string = 'MSF@rsi2024!@#'
param backpoolid string = 'id'

// param ruleid string = 'id'

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = virtualNetworkId
//var vnetName = last(split(vnetId, '/'))
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          loadBalancerBackendAddressPools: [
            {
              id: backpoolid
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroup
  ]
}




resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 300
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'WEB'
        properties: {
          priority: 301
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
    ]  
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-hotpatch'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource deploymentscript 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  parent: virtualMachine
  name: 'install-iis'
  location: location
  properties: {
    source: {
      script: '''Install-WindowsFeature -name Web-Server -IncludeManagementTools
      Install-WindowsFeature -name Web-Asp-Net45
      Remove-Item C:\inetpub\wwwroot\iisstart.htm
      Add-Content -Path 'C:\inetpub\wwwroot\iisstart.htm' -Value $('hello world from ' + $env:computername)
      '''
    }
  }
}

output vnicid string = resourceId('Microsoft.Network/networkInterfaces',networkInterfaceName)
output vmid string = virtualMachine.id
output adminUsername string = adminUsername

