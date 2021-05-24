<#
    Change the variables to match the desired environment.
    Do not include the carats, e.g. "<change-me>" should end up with a value like "changed"
#>

#Provide the subscription Id
$subscriptionId = "949ce875-4a5d-4f96-8db1-4bbd2f68f6e8"
#Provide the name of your resource group with the snapshot
$resourceGroupName = "poc-rg"
#Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'testsnap'
# Change this for the desired VM OS Disk naming convention. 
# A number and "osdisk" label will be appended in the loop below
# For MediaComposer VM, replace xxxx with showCode. 
$prefix = "show-edit"
#Start number for naming. E.g. if 1, the first disk will be <name>-01-osdisk
$vmStartIndex = 1
<#
    Last number for naming. E.g. if 10, the last disk will be <name>-10-osdisk
    If the start index is 1 and end index is 10, then 10 disks will be created 1-10
    If the start index is 11 and end index is 40, then 30 disks will be created 11-40
#>
$vmEndIndex = 2


##################### Nothing to change below here ###########################
#Set the context to the subscription Id where Managed Disk will be created
Select-AzSubscription -SubscriptionId $SubscriptionId
#The below loop will create the set number of VM clones.
for($i = $vmStartIndex; $i -le $vmEndIndex; $i += 1) {
    #Name of the OS disk that will be created using the snapshot
    $osDiskName = "$prefix-os-disk-{0:d2}" -f $i

    Write-Host "Creating Disk $osDiskName"

    $snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName
 
    $diskConfig = New-AzDiskConfig -Location $snapshot.Location -Sku "Premium_LRS" -SourceResourceId $snapshot.Id -CreateOption Copy

    $disk = New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName
}