define input variable for VNET/SUBNET, VM, LB in main.bicep file 
login in Azure subscription
    az login 
create resource with main.bicep
    az deployment group create --resource-group sch-Mostafa-Mostafavinezhad-rg --template-file main.bicep  --name webapp 

this bicep file create 3 item in scenario 
1. 1*vm (2* subnet)
2. LB (front end,backend,heal probs,snat,dnat )
3. 2*vm(interface, vm)
create mault resource (backup vault+workspace+query+agent for vm)
