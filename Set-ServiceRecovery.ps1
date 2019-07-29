param
(
    [Parameter(Mandatory=$false)][string]$serviceName
)

if ($serviceName) {
    $services = Get-Service -Name $serviceName | Select Name, DisplayName
}
else {
    $services = Get-WmiObject win32_service -Filter "Name like 'IMS-%' or Name like 'MSSQL`$IMS%'"
}

if ($services -eq $null) {
    Write-Host "No services found by that name."
}
else {
    foreach ($service in $services) {
        sc.exe failure $service.Name reset= 3600 actions= restart/30000/run/30000//30000
        sc.exe failure $service.Name command= "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\scripts\ServiceUpdate.ps1 $($service.Name) /fail=%1%"
    }
}
