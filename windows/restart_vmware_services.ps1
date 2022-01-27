# Tim H 2019
# Powershell script
# Restart all VMware related services in Windows
foreach ($svc in Get-Service){
  if(($svc.displayname.StartsWith("VMware")) -AND ($svc.Status -eq "Running")) {
    Write-Output $svc.DisplayName
    Restart-Service -Force $svc.name
  }
}
