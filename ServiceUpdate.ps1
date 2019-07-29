$ComputerName = (Get-WmiObject Win32_Computersystem).name
$ServiceName = $args[0]
$ServiceDisplayName = (Get-Service $ServiceName).DisplayName
$TimesRestarted = $args[1]

$Status = (Get-Service $ServiceName).Status

if ($Status -ne "Running")
{
    Start-Service $ServiceName
}

function SendAlert
{
    $FromAddress = "HostedServiceFailure@xanatek.com"
    $ToAddress = "scott@xanatek.com"
    $MessageSubject = "Hosted Service Failure for $ComputerName"
    $MessageBody = "The $ServiceDisplayName ($ServiceName) service on $ComputerName has restarted $TimesRestarted times in the last hour, please investigate immediately."
    $SendingServer = "mail.xanatek.net"
    
    $EmailUsername = "HostedServiceFailure"
    $encrypted = Get-Content .\email.txt | ConvertTo-SecureString
    $EmailCredential = New-Object System.Management.Automation.PSCredential($EmailUsername, $encrypted)

    $SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, $MessageSubject, $MessageBody

    $SMTPClient = New-Object System.Net.Mail.SmtpClient $SendingServer
    $SMTPClient.Credentials = $EmailCredential
    $SMTPClient.Send($SMTPMessage)
}

SendAlert


