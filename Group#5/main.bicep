param location string = 'westeurope'

param vnetName string = 'vnet_webapp_prod_WestEU_01'
param vnetip string = '10.100.0.0/16'


param subnetName string = 'sbnet_webapp_prod_WestEU_01'
param subnetip string = '10.100.10.0/24'

param subnetName2 string = 'sbnet_webapp_prod_WestEU_02'
param subnetip2 string = '10.100.20.0/24'



module vnet 'LB/Modules/VNET.bicep'= {
 name: 'vnet1'
 params: {
  location: location
  subnetAddressSpace: subnetip
  subnetName: subnetName
  subnetAddressSpace2: subnetip2 
  subnetName2: subnetName2
  vnetAddressSpace: vnetip
  vnetName: vnetName
 }
}
output vnib_vnet string = vnet.outputs.vnetId
output snid string = vnet.outputs.subid1
output snid2 string = vnet.outputs.subid2


param lb_name string = 'lb-webapp-prod-WestEU-01'
param fip_name string = 'fip-webapp-prod-WestEU-01'
param bk_name string = 'back-webapp-prod-WestEU-01'
param hlprob_name string = 'prob-webapp-prod-WestEU-01'
param rule_name string = 'rule-webapp-prod-WestEU-01'


module lb 'LB/Modules/LB.bicep' = {
  name: 'lb'
  params: {
    lb_name: lb_name
    location: location
    fip_name: fip_name
    bk_name: bk_name
    healprob: hlprob_name
    rule_name: rule_name
  }
}
output backendpoolid string = lb.outputs.backpoolid




param virtualMachineName1 string = 'vm-webapp-prod-WestEU-01'
param osDiskType string = 'Premium_LRS'
param osDiskDeleteOption string = 'Delete'
param virtualMachineSize string = 'Standard_DS1_v2'

module vm1 'LB/Modules/VM.bicep' = {
  name: 'vm1'
  params:{
    backpoolid: lb.outputs.backpoolid
    location:location
    virtualMachineName: virtualMachineName1
    networkInterfaceName: '${virtualMachineName1}-nic'
    networkSecurityGroupName: '${virtualMachineName1}-nsg'
    subnetName: subnetName
    virtualNetworkId: vnet.outputs.vnetId
    virtualMachineComputerName: 'vm-webapp1'
    osDiskType: osDiskType
    osDiskDeleteOption: osDiskDeleteOption
    virtualMachineSize: virtualMachineSize
  }
}
output vnic_id string = vm1.outputs.vnicid



param virtualMachineName2 string = 'vm-webapp-prod-WestEU-02'

module vm2 'LB/Modules/VM.bicep' = {
  name: 'vm2'
  params:{
    backpoolid: lb.outputs.backpoolid
    location:location
    virtualMachineName: virtualMachineName2
    networkInterfaceName: '${virtualMachineName2}-nic'
    networkSecurityGroupName: '${virtualMachineName2}-nsg'
    subnetName: subnetName2
    virtualNetworkId: vnet.outputs.vnetId
    virtualMachineComputerName: 'vm-webapp2'
    osDiskType: osDiskType
    osDiskDeleteOption: osDiskDeleteOption
    virtualMachineSize: virtualMachineSize
  }
}
output vnic_id2 string = vm2.outputs.vnicid

