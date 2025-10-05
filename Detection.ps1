#get the disk we want
try
{
    $disk = get-volume -ErrorAction Stop | where {$_.DriveLetter -eq "C"} 
}
catch
{
    Write-Host "Get-Volume Failed"
    $ErrorMsg = $_.Exception.Message
    Write-Error $ErrorMsg
}
    
#convert FreeSpace to GB
$FreeSpace = [math]::Round($disk.SizeRemaining / 1GB, 2) 

#convert total space to GB
$TotalSpace = [math]::Round($disk.Size /1GB, 2)

#Calculate the percentage
try
{
    $Percentage = 100 - [math]::Round(($FreeSpace / $TotalSpace), 2) * 100 
}
catch
{
    write-Host "Percentage Calculation Failed"
    $ErrorMsg = $_.Exception.Message
    Write-Error $ErrorMsg
}
if($FreeSpace -le 20) #If less than 20GB call remediation
{
    Write-Host "Storage is Low! TotalSpace: $TotalSpace GB /  FreeSpace: $FreeSpace GB. Disk is $Percentage% Full"

    Exit 1
}
else
{
    Write-Host "Storage is Ok! TotalSpace: $TotalSpace GB /  FreeSpace: $FreeSpace GB. Disk is $Percentage% Full"

    Exit 0
}
        


