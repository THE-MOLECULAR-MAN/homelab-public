# Download and install psexec from sysinternals
wget "https://download.sysinternals.com/files/PSTools.zip"  -OutFile "$HOME\PSTools.zip"

# Extract the file into "$HOME\PSTools"
Expand-Archive -Path PSTools.zip

# change directories, also verifies that path exists
cd "$HOME\PSTools"

# see username before psexec
whoami

# launches new window
.\psexec.exe -i -s "$PSHome\powershell.exe"

# creating a Windows shortcut to run Powershell as SYSTEM user
# Powershell v1: 
# C:\Users\thonker.adm\PSTools\PsExec.exe -i -s "%windir%\system32\WindowsPowerShell\v1.0\powershell.exe"

# Powershell v7:
# C:\Users\thonker.adm\PSTools\PsExec.exe -i -s "C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory ~

# verify that I'm now nt authority\system
whoami
