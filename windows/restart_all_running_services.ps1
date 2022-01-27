# Tim H 2019
# Powershell script to restart all of the services that are currently running
foreach ($svc in Get-Service){
  if($svc.Status -eq "Running") {
    Write-Output $svc.DisplayName
    # Restart-Service -Force $svc.name   # Don't do this, results in "Can't accept control messages" errors
    Restart-Service $svc.name
  }
}
