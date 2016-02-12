
####################################
# usage example
####################################

#. .\azure-vnet-lib.ps1
 
# $workingVnetConfig = get-azurenetworkxml
 
# add-azureVnetNetwork -networkName "Mynetwork" -affinityGroup "MyAzureAffinity" -addressPrefix "10.0.0.0/8"
# add-azureVnetSubnet -networkName "Mynetwork" -subnetName "subnet-1" -addressPrefix "10.0.0.0/11"
# add-azureVNetDns -dnsName "test1" -dnsAddress "10.0.0.1"
# add-azureVnetDnsRef -networkName "Mynetwork" -dnsName "test1"
# save-azurenetworkxml($workingVnetConfig)


#Get-azureNetworkXml
########################
#get-azureNetworkXml runs the get-AzureVNetConfig command. It takes the XMLConfiguration from that command and puts it into a new XML object. If there is no configuration, it creates a new xml object. It then checks to see if the main XML elements are present and, if not, creates them.
#Whilst this function returns an object, I need to make sure (right now) that the variable nme I use for that is $workingVnetConfig as other functions reference it. I’m not currently passing the XML object into each function. I probably should, but that tidying comes later.

function get-azureNetworkXml
{
 
$currentVNetConfig = get-AzureVNetConfig
if ($currentVNetConfig -ne $null)
{
[xml]$workingVnetConfig = $currentVNetConfig.XMLConfiguration
} else {
$workingVnetConfig = new-object xml
}
 
$networkConfiguration = $workingVnetConfig.GetElementsByTagName("NetworkConfiguration")
if ($networkConfiguration.count -eq 0)
{
$newNetworkConfiguration = create-newXmlNode -nodeName "NetworkConfiguration"
$newNetworkConfiguration.SetAttribute("xmlns:xsd","http://www.w3.org/2001/XMLSchema")
$newNetworkConfiguration.SetAttribute("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
$networkConfiguration = $workingVnetConfig.AppendChild($newNetworkConfiguration)
}
 
$virtualNetworkConfiguration = $networkConfiguration.GetElementsByTagName("VirtualNetworkConfiguration")
if ($virtualNetworkConfiguration.count -eq 0)
{
$newVirtualNetworkConfiguration = create-newXmlNode -nodeName "VirtualNetworkConfiguration"
$virtualNetworkConfiguration = $networkConfiguration.AppendChild($newVirtualNetworkConfiguration)
}
 
$dns = $virtualNetworkConfiguration.GetElementsByTagName("Dns")
if ($dns.count -eq 0)
{
$newDns = create-newXmlNode -nodeName "Dns"
$dns = $virtualNetworkConfiguration.AppendChild($newDns)
}
 
$virtualNetworkSites = $virtualNetworkConfiguration.GetElementsByTagName("VirtualNetworkSites")
if ($virtualNetworkSites.count -eq 0)
{
$newVirtualNetworkSites = create-newXmlNode -nodeName "VirtualNetworkSites"
$virtualNetworkSites = $virtualNetworkConfiguration.AppendChild($newVirtualNetworkSites)
}
 
return $workingVnetConfig
}


#Save-azureNetworkXml
##########################
#Save-azureNetworkXml gets passed our XML object, writes it out to a file in the temp dir and then calls set-AzureVNetConfig to load the file and send it to Azure.

function save-azureNetworkXml($workingVnetConfig)
{
$tempFileName = $env:TEMP + "\azurevnetconfig.netcfg"
$workingVnetConfig.save($tempFileName)
#notepad $tempFileName
set-AzureVNetConfig -configurationpath $tempFileName
}


#Add-azureVnetNetwork
#########################
#Add-azureVnetNetwork is called with three parameters: networkName, affinityGroup and addressPrefix. It will add a new VirtualNetworkSite element, with the name and affinity group as attributes. It checks to make sure the affinity group exists first. It then creates the address prefix within the network.

function add-azureVnetNetwork
{
param
(
[string]$networkName,
[string]$affinityGroup,
[string]$addressPrefix
)
 
#check if the network already exists
$networkExists = $workingVnetConfig.GetElementsByTagName("VirtualNetworkSite") | where {$_.name -eq $networkName}
if ($networkExists.Count -ne 0)
{
    write-Output "Network $networkName already exists"
    $newNetwork = $null
    return $newNetwork
}
  
#check that the target affinity group exists
$affinityGroupExists = get-AzureAffinityGroup | where {$_.name -eq $affinityGroup}
if ($affinityGroupExists -eq $null)
{
    write-Output "Affinity group $affinityGroup does not exist"
    $newNetwork = $null
    return $newNetwork
}
 
#get the parent node
$workingNode = $workingVnetConfig.GetElementsByTagName("VirtualNetworkSites")
#add the new network node
$newNetwork = create-newXmlNode -nodeName "VirtualNetworkSite"
$newNetwork.SetAttribute("name",$networkName)
$newNetwork.SetAttribute("AffinityGroup",$affinityGroup )
$network = $workingNode.appendchild($newNetwork)
 
#add new address space node
$newAddressSpace = create-newXmlNode -nodeName "AddressSpace"
$AddressSpace = $Network.appendchild($newAddressSpace)
$newAddressPrefix = create-newXmlNode -nodeName "AddressPrefix"
$newAddressPrefix.InnerText=$addressPrefix
$AddressSpace.appendchild($newAddressPrefix)
 
#return our new network
$newNetwork = $network
return $newNetwork
 
}

#Add-azureVnetSubnet
########################
#Add-azureVnetSubnet takes three parameters: networkName, subnetName and addressPrefix. It makes sure the network exists, that the subnet doesn’t, and that the address prefix is not already used in the same network. It then adds the subnet to the network.

function add-azureVnetSubnet
{
param
(
[string]$networkName,
[string]$subnetName,
[string]$addressPrefix
)
 
#get our target network
$workingNode = $workingVnetConfig.GetElementsByTagName("VirtualNetworkSite") | where {$_.name -eq $networkName}
if ($workingNode.Count -eq 0)
{
    write-Output "Network $networkName does not exist"
    $newSubnet = $null
    return $newSubnet
}
 
#check if the subnets node exists and if not, create
$subnets = $workingNode.GetElementsByTagName("Subnets")
if ($subnets.count -eq 0)
{
$newSubnets = create-newXmlNode -nodeName "Subnets"
$subnets = $workingNode.appendchild($newSubnets)
}
 
#check to make sure our subnet name doesn't exist and/or prefix isn't already there
$subNetExists = $workingNode.GetElementsByTagName("Subnet") | where {$_.name -eq $subnetName}
if ($subNetExists.count -ne 0)
{
    write-Output "Subnet $subnetName already exists"
    $newSubnet = $null
    return $newSubnet
}
$subNetExists = $workingNode.GetElementsByTagName("Subnet") | where {$_.AddressPrefix -eq $subnetName}
if ($subNetExists.count -ne 0)
{
    write-Output "Address prefix $addressPrefix already exists in another network"
    $newSubnet = $null
    return $newSubnet
}
 
#add the subnet
$newSubnet = create-newXmlNode -nodeName "Subnet"
$newSubnet.SetAttribute("name",$subnetName)
$subnet = $subnets.appendchild($newSubnet)
$newAddressPrefix = create-newXmlNode -nodeName "AddressPrefix"
$newAddressPrefix.InnerText = $addressPrefix
$subnet.appendchild($newAddressPrefix)
 
#return our new subnet
$newSubnet = $subnet
return $newSubnet
}

#Add-azureVnetDns
#####################
#Add-azureVnetDns takes two parameters: dnsName and dnsAddress. It then creates a new DnsServer element for that DNS.

function add-azureVnetDns
{
param
(
[string]$dnsName,
[string]$dnsAddress
)
 
#check that the DNS does not exist
$dnsExists = $workingVnetConfig.GetElementsByTagName("DnsServer") | where {$_.name -eq $dnsName}
if ($dnsExists.Count -ne 0)
{
    write-Output "DNS Server $dnsName already exists"
    $newDns = $null
    return $newDns
}
# get our working node of Dns
$workingNode = $workingVnetConfig.GetElementsByTagName("Dns")
 
#check if the DnsServersRef node exists and if not, create
$dnsServers = $workingNode.GetElementsByTagName("DnsServers")
if ($dnsServers.count -eq 0)
{
$newDnsServers = create-newXmlNode -nodeName "DnsServers"
$dnsServers = $workingNode.appendchild($newDnsServers)
}
 
#add new dns reference
$newDnsServer = create-newXmlNode -nodeName "DnsServer"
$newDnsServer.SetAttribute("name",$dnsName)
$newDnsServer.SetAttribute("IPAddress",$dnsAddress)
$newDns = $dnsServers.appendchild($newDnsServer)
 
#return our new dnsRef
return $newDns
 
}

#Add-azureVnetDnsRef
###########################
#Add-azureVnetDnsRef takes two parameters; networkName and dnsName. It makes sure the network exists and that the DNS exists before adding a DnsServerRef element for the DNS to the network.

function add-azureVnetDnsRef
{
param
(
[string]$networkName,
[string]$dnsName
)
 
#get our target network
$workingNode = $workingVnetConfig.GetElementsByTagName("VirtualNetworkSite") | where {$_.name -eq $networkName}
if ($workingNode.count -eq 0)
{
    write-Output "Network $networkName does not exist"
    $newSubnet = $null
    return $newSubnet
}
 
#check if the DnsServersRef node exists and if not, create
$dnsServersRef = $workingNode.GetElementsByTagName("DnsServersRef")
if ($dnsServersRef.count -eq 0)
{
$newDnsServersRef = create-newXmlNode -nodeName "DnsServersRef"
$dnsServersRef = $workingNode.appendchild($newDnsServersRef)
}
 
#check that the DNS we want to reference is defined already
$dnsExists = $workingVnetConfig.GetElementsByTagName("DnsServer") | where {$_.name -eq $dnsName}
if ($dnsExists.Count -eq 0)
{
    write-Output "DNS Server $dnsName does not exist so cannot be referenced"
    $newDnsRef = $null
    return $newDnsRef
}
 
#check that the dns reference isn't already there
$dnsRefExists = $workingNode.GetElementsByTagName("DnsServerRef") | where {$_.name -eq $dnsName}
if ($dnsRefExists.count -ne 0)
{
    write-Output "DNS reference $dnsName already exists"
    $newDnsRef = $null
    return $newDnsRef
}
 
#add new dns reference
$newDnsServerRef = create-newXmlNode -nodeName "DnsServerRef"
$newDnsServerRef.SetAttribute("name",$dnsName)
$newDnsRef = $dnsServersRef.appendchild($newDnsServerRef)
 
#return our new dnsRef
return $newDnsRef
 
}

#Create-newXmlNode
########################
#Create-newXmlNode is called by all the other functions. It creates a new node in the XML object then hands it back to the calling function for modification and appending it to the relevant parent node.

function create-newXmlNode
{
param
(
[string]$nodeName
)
 
$newNode = $workingVnetConfig.CreateElement($nodeName,"http://schemas.microsoft.com/ServiceHosting/2011/07/NetworkConfiguration")
return $newNode
}









