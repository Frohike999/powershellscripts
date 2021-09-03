Param(
    [switch]$Email = $false,
    [string]$Recipients = $null
) 
$Results = New-Object System.Collections.ArrayList

$ComputerName = Get-ComputerInfo -Property CsName | Select -ExpandProperty CsName

if ($Email -eq $true){
    $EmailCredentials = New-Object System.Net.NetworkCredential("scott", "avett81");cd
    $To = @(($Recipients) -split ',')
    $Attachment = ("c:\ScriptOutput\{0}-Inventory.csv" -f $ComputerName)
    $Attachment += ("c:\ScriptOutput\{0}-FolderList.csv" -f $ComputerName)
    $From = $EmailCredentials.UserName

    $EmailParameters = @{
        To = $To
        Subject = ("{0} Report" -f $ComputerName)
        Body = ("Please find attached the report for {0}." -f $ComputerName)
        Attachments = $Attachment
        UseSsl = $True
        Port = "587"
        SmtpServer = "mail.xanatek.net"
        Credential = $EmailCredentials
        From = $From
        }
}

$ComputerInfo = New-Object System.Object

$ComputerInfoOperatingSystem = Get-ComputerInfo -Property OsName | Select -ExpandProperty OsName
$ComputerInfoOperatingSystemServicePack = Get-ComputerInfo -Property OsServicePackMajorVersion | Select -ExpandProperty OsServicePackMajorVersion

$ComputerInfo | Add-Member -MemberType NoteProperty -Name "Name" -Value "$ComputerName" -Force
$ComputerInfo | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $ComputerInfoOperatingSystem
$ComputerInfo | Add-Member -MemberType NoteProperty -Name "ServicePack" -Value $ComputerInfoOperatingSystemServicePack

#SQL Server Info
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$SqlServer = New-Object "Microsoft.SqlServer.Management.Smo.Server" "localhost\IMS1"
$SQLServerVersion = $SqlServer.Version
$SQLServerEdition = $SQLServer.Edition
$SQLServer.DatabaseEngineEdition

$ComputerInfo | Add-Member -MemberType NoteProperty -Name "SQLServerVersion" -Value $SQLServerVersion
$ComputerInfo | Add-Member -MemberType NoteProperty -Name "SQLServerEdition" -Value $SQLServerEdition

# Hard drive Info
$ComputerDisks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" |
    select DeviceID,VolumeName, @{Expression={[math]::Round($_.FreeSpace / 1GB, 2)};Label="FreeSpaceGB"}, @{Expression={[math]::Round($_.Size / 1GB, 2)};Label="TotalSpaceGB"}

foreach ($Disk in $ComputerDisks) 
{
    $ComputerInfoDiskDrive = $Disk.DeviceID
    $ComputerInfoDriveName = $Disk.VolumeName
    $ComputerInfoSize = $Disk.TotalSpaceGB
    $ComputerInfoFreeSpace = $Disk.FreeSpaceGB
    $ComputerInfoDiskPercentage = [math]::Round(([int]$ComputerInfoFreeSpace / [int]$ComputerInfoSize) * 100)
    
    $ComputerInfo | Add-Member -MemberType NoteProperty -Name ("{0} DeviceID" -f $ComputerInfoDiskDrive) -Value $ComputerInfoDiskDrive 
    $ComputerInfo | Add-Member -MemberType NoteProperty -Name ("{0} DriveName" -f $ComputerInfoDiskDrive) -Value $ComputerInfoDriveName 
    $ComputerInfo | Add-Member -MemberType NoteProperty -Name ("{0} FreeSpaceGB" -f $ComputerInfoDiskDrive) -Value $ComputerInfoFreeSpace 
    $ComputerInfo | Add-Member -MemberType NoteProperty -Name ("{0} TotalSpaceGB" -f $ComputerInfoDiskDrive) -Value $ComputerInfoSize 
    $ComputerInfo | Add-Member -MemberType NoteProperty -Name ("{0} PercentUsed" -f $ComputerInfoDiskDrive) -Value $ComputerInfoDiskPercentage
    }
    
# Get folder list and sizes

cd D:\IMS
$IMSFolderList = Get-ChildItem | ?{ $_.PSIsContainer } | Select-Object FullName

foreach ($i in $IMSFolderList) {

   $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
   $i.FullName = $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
}

cd "D:\IMS Backups"
$IMSBackupFolderList = Get-ChildItem | ?{ $_.PSIsContainer } | Select-Object FullName

foreach ($i in $IMSBackupFolderList) {

   $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
   $i.FullName = $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
}

$Results.Add($ComputerInfo) | Out-Null

$Results | Export-Csv ("c:\ScriptOutput\{0}-Inventory.csv" -f $ComputerName) -NoTypeInformation
$IMSFolderList | Export-Csv ("c:\ScriptOutput\{0}-FolderList.csv" -f $ComputerName) -NoTypeInformation
$IMSBackupFolderList | Export-Csv ("c:\ScriptOutput\{0}-FolderList.csv" -f $ComputerName) -NoTypeInformation -Append

if ($Email -eq $true) {Send-MailMessage @EmailParameters}