###########################
# Parameters
###########################

. .\azure-create-labenv-paramters.ps1

############################################
# Create New VMs
############################################
# ref: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-ps-create-preconfigure-windows-vms/
Write-Host  "Create New VMs ..."

#Set default subscription and CurrentStorageAccountName
$myDefaultSubscriptions = Get-AzureSubscription -SubscriptionName $sourceSubscriptionName
Select-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -Current
Set-AzureSubscription -SubscriptionId $myDefaultSubscriptions.SubscriptionId -CurrentStorageAccountName $myStorageAccountName

# Get all Image Names (comment this before running)
# Get-AzureVMImage | select ImageFamily -Unique
# Get-AzureVMImage | select Label -Unique

# Windows 
$myWinImageFamily = "Windows Server 2012 R2 Datacenter (zh-cn)"
$myWinVmName = "labclient01"
#Allowed values are 'ExtraSmall, Small, Medium, Large,ExtraLarge,
#A5,A6,A7,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,
#Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14'.
$myWinVmSize = "Medium";

$myWinImage=Get-AzureVMImage | where { $_.ImageFamily -eq $myWinImageFamily } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$myWinVmConfig = New-AzureVMConfig -Name $myWinVmName -InstanceSize $myWinVmSize -ImageName $myWinImage
$myWinVmConfig | Set-AzureSubnet -SubnetNames $myVNet_Subnet1
$myWinVmConfig | Set-AzureStaticVNetIP -IPAddress 10.0.0.10
$myWinVmCred = Get-Credential -Message "Enter username and password for the VM [$($myVmName)]"
$myWinVmConfig | Add-AzureProvisioningConfig -Windows -AdminUsername $myWinVmCred.UserName -Password $myWinVmCred.GetNetworkCredential().Password

New-AzureVM -ServiceName $myCloudServiceName -VMs $myWinVmConfig -VNetName $myVNetName

# Windows - join domain when created
$myWinImageFamily = "Windows Server 2012 R2 Datacenter (zh-cn)"
$myWinVmName = "labclient01"
#Allowed values are 'ExtraSmall, Small, Medium, Large,ExtraLarge,
#A5,A6,A7,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,
#Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14'.
$myWinVmSize = "Medium";

$myWinImage=Get-AzureVMImage | where { $_.ImageFamily -eq $myWinImageFamily } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$myWinVmConfig = New-AzureVMConfig -Name $myWinVmName -InstanceSize $myWinVmSize -ImageName $myWinImage
$myWinVmConfig | Set-AzureSubnet -SubnetNames $myVNet_Subnet1
$myWinVmConfig | Set-AzureStaticVNetIP -IPAddress 10.0.0.10
$myWinVmCred = Get-Credential -Message "Setup LocalAdmin the VM [$($myWinVmName)]"
$myWinVmDomainCred = Get-Credential -Message "Setup Domain User for the VM [$($myWinVmName)]"
$myWinVmDomainFQDN = "vsalm.local"
$myWinVmDomainName = "VSALM"
$myWinVmConfig | Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $myWinVmDomainFQDN -Domain $myWinVmDomainName -DomainUserName $myWinVmDomainCred.GetNetworkCredential().UserName -DomainPassword $myWinVmDomainCred.GetNetworkCredential().Password -AdminUsername $myWinVmCred.GetNetworkCredential().UserName -Password $myWinVmCred.GetNetworkCredential().Password

New-AzureVM -ServiceName $myCloudServiceName -VMs $myWinVmConfig -VNetName $myVNetName

# Linux
$myLinuxImageFamily = "OpenLogic 7.0"
$myLinuxVmName = "Guacamole"
#Allowed values are 'ExtraSmall, Small, Medium, Large,ExtraLarge,
#A5,A6,A7,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,
#Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14'.
$myLinuxVmSize = "Small";

$myLinuxImage = Get-AzureVMImage | where { $_.Label -eq $myLinuxImageFamily } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$myLinuxVmConfig = New-AzureVMConfig -Name $myLinuxVmName -InstanceSize $myLinuxVmSize -ImageName $myLinuxImage
$myLinuxCred=Get-Credential -Message "Type the name and password of the initial Linux account."
$myLinuxVmConfig | Add-AzureProvisioningConfig -Linux -LinuxUser $myLinuxCred.GetNetworkCredential().Username -Password $myLinuxCred.GetNetworkCredential().Password
$myLinuxVmConfig | Set-AzureSubnet $myVNet_Subnet1
$myLinuxVmConfig | Set-AzureStaticVNetIP -IPAddress 10.0.0.5

New-AzureVM -ServiceName $myCloudServiceName -VMs $myLinuxVmConfig -VNetName $myVNetName


