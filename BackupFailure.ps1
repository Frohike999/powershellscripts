$ComputerName = (Get-WmiObject Win32_Computersystem).name
$time = (Get-Date).AddDays(-6)
$Path1 = 'D:\IMS Backups'
$Path2 = 'X:\'


$FileList = Get-ChildItem -Path $Path1, $Path2 -Recurse -File -Exclude ims_DIFF* |
    Where-Object {$_.LastWriteTime -lt $time} | Select-Object FullName, LastWriteTime

  Where-Object {$_.LastWriteTime -lt $time} | Select-Object FullName, LastWriteTime

function SendAlert
{
    $FromAddress = "HostedServiceBackups@xanatek.com"
    $ToAddress = "scott@xanatek.com"
    $MessageSubject = "Hosted Service Full Backup Problem for $ComputerName"
    $MessageBody = "The backups located in the following directories do not have a recent full backup $FileList`r`n`n<table><tr><th><b>File</b></th><th><b>Last Modified</b></th></tr>"

    foreach($File in $FileList) {
        $MessageBody += "<tr><td>$($File.FullName)</td><td>$($File.LastWriteTime)</td></tr>";
        }
    $MessageBody += "</table>"

    $SendingServer = "xanatek-com.mail.protection.outlook.com"

    $SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, $MessageSubject, $MessageBody
    $SMTPMessage.IsBodyHtml = $true

    $SMTPClient = New-Object System.Net.Mail.SmtpClient $SendingServer
    $SMTPClient.Send($SMTPMessage)
}

if ($FileList.Count -gt 0) {
    SendAlert
}