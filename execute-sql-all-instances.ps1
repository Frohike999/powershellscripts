//Applies SQL script to all SQL instances on a computer. In the command below, SYSTEM is given sysadmin role for each instance.

$i = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | ForEach-Object { "localhost\$_" }

foreach ($instance in $i) { 
  Invoke-Sqlcmd "EXEC master..sp_addsrvrolemember @loginame = N'NT AUTHORITY\SYSTEM', @rolename = N'sysadmin'" -ServerInstance $instance 
}
