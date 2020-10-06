<#
    Change the variables to match the desired environment.
    Do not include the carats, e.g. "<change-me>" should end up with a value like "changed"
#>

#Provide the subscription Id
$subscriptionId = "63e4095b-6f13-45ed-9386-af1b8f8c1a40"
#Provide the name of your resource group with the snapshot
$resourceGroupName = "sb-test-eus-mc"
#Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'mc-os-disk-snapshot'
# Change this for the desired VM OS Disk naming convention. 
# A number and "osdisk" label will be appended in the loop below
# e.g. with a prefix "ams-edit" the names will look like: ams-edit-001-osdisk
$vmNamePrefix = "test-edit"
#Start number for naming. E.g. if 1, the first disk will be <name>-001-osdisk
$vmStartIndex = 1
<#
    Last number for naming. E.g. if 10, the last disk will be <name>-010-osdisk
    If the start index is 1 and end index is 10, then 10 disks will be created 1-10
    If the start index is 11 and end index is 40, then 30 disks will be created 11-40
#>
$vmEndIndex = 3


##################### Nothing to change below here ###########################
#Set the context to the subscription Id where Managed Disk will be created
Select-AzSubscription -SubscriptionId $SubscriptionId
#The below loop will create the set number of VM clones.
for($i = $vmStartIndex; $i -le $vmEndIndex; $i += 1) {
    #Name of the OS disk that will be created using the snapshot
    $osDiskName = "$vmNamePrefix-{0:d3}-osdisk" -f $i

    Write-Host "Creating Disk $osDiskName"
    $snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName
 
    $diskConfig = New-AzDiskConfig -Location $snapshot.Location -Sku "Premium_LRS" -SourceResourceId $snapshot.Id -CreateOption Copy

    $disk = New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName
}