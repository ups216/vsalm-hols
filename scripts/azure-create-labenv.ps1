# Get your azure scription setup correctly before running these scripts

# ref: https://blogs.blackmarble.co.uk/blogs/rhepworth/post/2014/03/03/Creating-Azure-Virtual-Networks-using-Powershell-and-XML.aspx 

###########################
# Parameters
###########################

. .\azure-create-labenv-paramters.ps1

####################################################### 
#Setup Subscriptions
####################################################### 
#Source  
$source=($dataDir)+"\"+($sourceSubscriptionSettingFile);
Import-AzurePublishSettingsFile -PublishSettingsFile $source
Select-AzureSubscription -SubscriptionName $sourceSubscriptionName

###################################
# Create New-AzureAffinityGroup
###################################
Write-Host  "Create New-AzureAffinityGroup ..."
New-AzureAffinityGroup -Name $myAffinityGroup -Location $myLocation

###################################
# Create New VNetwork
###################################
Write-Host  "Create Create New VNetwork ..."
. .\azure-vnet-lib.ps1
 
$workingVnetConfig = get-azurenetworkxml
 
add-azureVnetNetwork -networkName $myVNetName -affinityGroup $myAffinityGroup -addressPrefix "10.0.0.0/8"
add-azureVnetSubnet -networkName $myVNetName -subnetName $myVNet_Subnet1 -addressPrefix "10.0.0.0/11"
add-azureVNetDns -dnsName $myDnsName -dnsAddress "10.0.0.1"
add-azureVnetDnsRef -networkName $myVNetName -dnsName $myDnsName
save-azurenetworkxml($workingVnetConfig)

###################################
# Create New Cloud Service
###################################
#ref: https://azure.microsoft.com/en-us/documentation/articles/cloud-services-powershell-create-cloud-container/?cdn=disable

Write-Host  "Create New Cloud Service ..."
New-AzureService -ServiceName $myCloudServiceName -AffinityGroup $myAffinityGroup -Label $myCloudServiceName 

############################################
# Create New Storage account and containers
############################################
#ref: https://azure.microsoft.com/en-us/documentation/articles/storage-powershell-guide-full/

Write-Host  "Create New Storage account and containers ..."
New-AzureStorageAccount -StorageAccountName $myStorageAccountName -AffinityGroup $myAffinityGroup

#Set default subscription and CurrentStorageAccountName
$myDefaultSubscriptions = Get-AzureSubscription -SubscriptionName $sourceSubscriptionName
Select-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -Current
Set-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -CurrentStorageAccountName $myStorageAccountName

#Create container for vhds
New-AzureStorageContainer -Name "vhds"

Write-Host  "... Done!"