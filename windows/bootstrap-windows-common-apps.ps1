# Downloads and silently installs a few common Windows tools:
#   * Chocolately
#   * Google Chrome
#   * OWASP ZAP
#   * Java JRE v8
# may be able to use the wget command instead if on newer versions of Windows/Powershell since
#   it acts as an alias for Invoke-WebRequest

cd $HOME\Downloads

# Install Windows package manager Chocolatey
# See more here: https://docs.chocolatey.org/en-us/choco/setup
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Test Chocolatey install by listing version
choco --version

# Download Google Chrome stub installer
# Offline installer URL isn't friendly and is dynamic.
Invoke-WebRequest https://dl.google.com/chrome/install/latest/chrome_installer.exe -OutFile ChromeSetup.exe
.\ChromeSetup.exe /silent /install

# Download OWASP ZAP
# See the latest version here:  https://github.com/zaproxy/zaproxy/releases/latest
# Silent install documentation: https://www.ej-technologies.com/resources/install4j/help/doc/installers/installerModes.html
Invoke-WebRequest https://github.com/zaproxy/zaproxy/releases/download/v2.11.1/ZAP_2_11_1_windows.exe  -OutFile ZAP_installer_windows.exe
.\ZAP_installer_windows.exe -q

# Download Java Runtime for Win64
# Download Java manually here: https://www.java.com/en/download/manual.jsp
# https://www.java.com/en/download/help/silent_install.html
Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245805_df5ad55fdd604472a86a45a217032c7d -OutFile Java_Installer_Windows64.exe
.\Java_Installer_Windows64.exe /s
