# clear ALL Windows Event logs using PowerShell v1
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
