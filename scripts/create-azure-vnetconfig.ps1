# Get your azure scription setup correctly before running these scripts

# ref: https://blogs.blackmarble.co.uk/blogs/rhepworth/post/2014/03/03/Creating-Azure-Virtual-Networks-using-Powershell-and-XML.aspx 

# Parameters
$myLocation = "China North"
$myAffinityGroup = "azurelab001-ag"
$myVNetName = "azurelab001-vnet"
$myDnsName = "azurelab001-dns"
$myCloudServiceName = "azurelab001-as"
$myStorageAccountName = "azurelab001sc"

###################################
# Create New-AzureAffinityGroup
###################################
New-AzureAffinityGroup -Name $myAffinityGroup -Location $myLocation

###################################
# Create New VNetwork
###################################

. .\azure-vnet-lib.ps1
 
$workingVnetConfig = get-azurenetworkxml
 
add-azureVnetNetwork -networkName $myVNetName -affinityGroup $myAffinityGroup -addressPrefix "10.0.0.0/8"
add-azureVnetSubnet -networkName $myVNetName -subnetName "subnet-1" -addressPrefix "10.0.0.0/11"
add-azureVNetDns -dnsName $myDnsName -dnsAddress "10.0.0.1"
add-azureVnetDnsRef -networkName $myVNetName -dnsName $myDnsName
save-azurenetworkxml($workingVnetConfig)

###################################
# Create New Cloud Service
###################################

#ref: https://azure.microsoft.com/en-us/documentation/articles/cloud-services-powershell-create-cloud-container/?cdn=disable

New-AzureService -ServiceName $myCloudServiceName -AffinityGroup $myAffinityGroup -Label $myCloudServiceName 

############################################
# Create New Storage account and containers
############################################

#ref: https://azure.microsoft.com/en-us/documentation/articles/storage-powershell-guide-full/

New-AzureStorageAccount -StorageAccountName $myStorageAccountName -AffinityGroup $myAffinityGroup

