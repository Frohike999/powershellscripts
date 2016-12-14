$filedirectory = "C:\Shares\IMS3\Program\images\"
Get-ChildItem "$filedirectory" -Recurse |
foreach-object -process {if ($_.Name -match "(CLI)(\d+)(\.cif)") {rename-item -path $_.FullName -NewName ($_.DirectoryName+"\"+$Matches[1]+([int]$Matches[2]+100000)+$Matches[3])}}
