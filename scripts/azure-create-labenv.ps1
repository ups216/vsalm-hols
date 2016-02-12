# Get your azure scription setup correctly before running these scripts

# ref: https://blogs.blackmarble.co.uk/blogs/rhepworth/post/2014/03/03/Creating-Azure-Virtual-Networks-using-Powershell-and-XML.aspx 

###########################
# Parameters
###########################

# Master Name
$labName = "azurelab003"
$dataDir = "d:\data"

# Subscription
$sourceSubscriptionName = 'LeiXuPrepaid'
$sourceSubscriptionSettingFile = 'LeiXuPrepaid-LeiXuVSEnterprisePrepaid-2-12-2016-credentials.publishsettings'

# Networking, Storage and Cloud Service
$myLocation = "China North"
$myAffinityGroup = "$($labName)-ag"
$myVNetName = "$($labName)-vnet"
$myVNet_Subnet1 = "subnet-1"
$myDnsName = "$($labName)-dns"
$myCloudServiceName = $($labName)
$myStorageAccountName = "$($labName)sa"

# Machines
$myImageFamily = "Windows Server 2012 R2 Datacenter (zh-cn)"
$myVmName = "TFS2015U1CHS"
#Allowed values are 'ExtraSmall, Small, Medium, Large,ExtraLarge,A5,A6,A7,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,Standard_D1,Standard_D2,Standard_D3,Standard_D4,Stand
#ard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12
#,Standard_DS13,Standard_DS14'.
$myVmSize = "Small";

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
$myDefaultSubscriptions = Get-AzureSubscription -Default
Select-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -Current
Set-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -CurrentStorageAccountName $myStorageAccountName

#Create container for vhds
New-AzureStorageContainer -Name "vhds"

############################################
# Create New VMs
############################################
# ref: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-ps-create-preconfigure-windows-vms/
Write-Host  "Create New VMs ..."

# Get all Image Names (comment this before running)
# Get-AzureVMImage | select ImageFamily -Unique

$image=Get-AzureVMImage | where { $_.ImageFamily -eq $myImageFamily } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$myVmConfig = New-AzureVMConfig -Name $myVmName -InstanceSize $myVmSize -ImageName $image
$myVmConfig | Set-AzureSubnet -SubnetNames $myVNet_Subnet1
$myVmCred = Get-Credential -Message "Enter username and password for the VM [$($myVmName)]"
$myVmConfig | Add-AzureProvisioningConfig -Windows -AdminUsername $myVmCred.UserName -Password $myVmCred.GetNetworkCredential().Password

New-AzureVM -ServiceName $myCloudServiceName -VMs $myVmConfig -VNetName $myVNetName

Write-Host  "... Done!"