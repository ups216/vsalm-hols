#######################################################
# 
# Copy VM Between Azure Environments
# Author: Lei Xu
# Date: 2014-10-12
#
####################################################### 

#Parameters
#######################################################
$workingDir = $PSScriptRoot
$dataDir = "d:\data"
$CloudEnv = 'AzureChinaCloud'

# Source
$sourceSubscriptionName = 'LeiXuVSEnterprisePrepaid'
$sourceSubscriptionSettingFile = 'LeiXuPrepaid-LeiXuVSEnterprisePrepaid-2-12-2016-credentials.publishsettings'
$vmName = "TFS2015U1CHS"
$sourceServiceName = "azurelab001"

# Target
$destSubscriptionName = 'LeiXuVSEnterprisePrepaid'
$destSubscriptionSettingFile = 'LeiXuPrepaid-LeiXuVSEnterprisePrepaid-2-12-2016-credentials.publishsettings'
$destVNetName = 'azurelab002-vnet'
$destStorageAccountName = 'azurelab002sa'
$destServiceName = 'azurelab002'

#######################################################
#Remove All Subscription
foreach ($item in  (Get-AzureSubscription))
 {
       Remove-AzureSubscription -SubscriptionId $item.SubscriptionId -Force
 }

#Setup Subscriptions
####################################################### 
#Source  
$source=($dataDir)+"\"+($sourceSubscriptionSettingFile);
Import-AzurePublishSettingsFile -PublishSettingsFile $source
#Target 
$target = ($dataDir)+"\"+($destSubscriptionSettingFile);
Import-AzurePublishSettingsFile -PublishSettingsFile $target
####################################################### 

#Get Source VM Disks
####################################################### 
Select-AzureSubscription -SubscriptionName $sourceSubscriptionName

#Get Source VM Data
$sourceVm = Get-AzureVM –ServiceName $sourceServiceName –Name $vmName
$vmConfigurationPath = $dataDir + "\$($vmName)-exportedVM.xml"
$sourceVm | Export-AzureVM -Path $vmConfigurationPath
$sourceOSDisk = $sourceVm.VM.OSVirtualHardDisk
$sourceDataDisks = $sourceVm.VM.DataVirtualHardDisks

$sourceStorageName = $sourceOSDisk.MediaLink.Host -split "\." | select -First 1
$sourceStorageAccount = Get-AzureStorageAccount –StorageAccountName $sourceStorageName
$sourceStorageKey = (Get-AzureStorageKey -StorageAccountName $sourceStorageName).Primary

#Stop-AzureVM –ServiceName $sourceServiceName –Name $vmName -Force
####################################################### 

#Get Dest VM Disks
####################################################### 
Select-AzureSubscription -SubscriptionName $destSubscriptionName

$destStorageAccount = Get-AzureStorageAccount -StorageAccountName $destStorageAccountName
$destStorageName = $destStorageAccount.StorageAccountName
$destStorageKey = (Get-AzureStorageKey -StorageAccountName $destStorageName).Primary
####################################################### 

#Get Source & Dest Storage Context and copy
####################################################### 
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageName -StorageAccountKey $sourceStorageKey -Environment $CloudEnv
$destContext = New-AzureStorageContext –StorageAccountName $destStorageName -StorageAccountKey $destStorageKey -Environment $CloudEnv
$allDisks = @($sourceOSDisk) + $sourceDataDisks
$destDataDisks = @()

foreach($disk in $allDisks)
{
    $blobName = $disk.MediaLink.Segments[2]
    $targetBlob = Start-CopyAzureStorageBlob -SrcContainer vhds -SrcBlob $blobName -DestContainer vhds -DestBlob $blobName -Context $sourceContext -DestContext $destContext -Force
    Write-host "Copying blob $blobName"
    $copyState = $targetBlob | Get-AzureStorageBlobCopyState
    while ($copyState.Status -ne "Success")
    {
        $percent = ($copyState.BytesCopied / $copyState.TotalBytes) * 100
        Write-host "Completed $('{0:N2}' -f $percent)%"
        sleep -Seconds 5
        $copyState = $targetBlob | Get-AzureStorageBlobCopyState
    }
    If ($disk -eq $sourceOSDisk)
    {
        $destOSDisk = $targetBlob
    }
    Else
    {
        $destDataDisks += $targetBlob
    }
}

####################################################### 
# change target machine and disk names
####################################################### 

$targetDiskName = $sourceOSDisk.DiskName + "-" + $destServiceName
(Get-Content $vmConfigurationPath).replace($sourceOSDisk.DiskName, $targetDiskName) | Set-Content $vmConfigurationPath

####################################################### 
#Create Target VM and Boot it up!
####################################################### 

Add-AzureDisk -OS $sourceOSDisk.OS -DiskName $targetDiskName -MediaLocation $destOSDisk.ICloudBlob.Uri
foreach($currenDataDisk in $destDataDisks)
{
    $diskName = ($sourceDataDisks | ? {$_.MediaLink.Segments[2] -eq $currenDataDisk.Name}).DiskName
    Add-AzureDisk -DiskName $diskName -MediaLocation $currenDataDisk.ICloudBlob.Uri 
}

Get-AzureSubscription -SubscriptionName $destSubscriptionName
Set-AzureSubscription -CurrentStorageAccountName $destStorageAccountName -SubscriptionName $destSubscriptionName 
$vmConfig = Import-AzureVM -Path $vmConfigurationPath
$vmConfig | Set-AzureSubnet "subnet-1" 

Write-Host  "New-AzureVM..."
New-AzureVM -ServiceName $destServiceName -VMs $vmConfig -VNetName $destVNetName 

Write-Host "Completed."
####################################################### 