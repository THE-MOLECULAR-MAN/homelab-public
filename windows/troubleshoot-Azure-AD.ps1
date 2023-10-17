# Most of these commands, but not all, needs admin perms - must be run in PowerShell with Administrator priv

# https://docs.microsoft.com/en-us/microsoft-365/business-premium/m365bp-manage-windows-devices?view=o365-worldwide

# force update of Group Policy
gpupdate /force

# test if joined to Azure AD or domain in general
dsregcmd /status

# see which GPOs are applied to local system
gpresult /Scope Computer /v

# see which GPOs are applied to current user
gpresult /Scope User /v

# diagnostics for Azure AD connector on domain controller, must install tool before running this command
Register-AzureADConnectHealthADDSAgent

# this must be run as NT AUTHORITY\SYSTEM using psexec
# see setup-psexec.ps1 for instructions on promoting user to system

# dsregcmd AD Configuration Test FAIL 0x80070002
# TenantInfo::Discover: Failed reading registration data from AD. Defaulting to autojoin disabled 0x80070002
#DsrCmdJoinHelper::Join: TenantInfo::Discover failed with error code 0x801c001d.
# https://social.msdn.microsoft.com/Forums/vstudio/en-US/e6a5850b-932f-42ec-99a2-cdc1df4f5619/hybrid-aad-join-issue?forum=WindowsAzureAD
#       Windows Server Manager > Tools > ADSI Edit
#       Connect to DC
#       Right click on the top level DC= object on the left, select properties
#       Security tab
#       Select Authenticated Users
#       Verify that group has Read access
#
# Checking local event logs
# https://docs.microsoft.com/en-us/answers/questions/297081/issue-with-hybrid-join-error-0x801c001d.html
sc start dmwappushsvc
# clear ALL Windows Event logs - Powershell v1-6
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }

# Powershell v7+
Import-Module Microsoft.PowerShell.Management
$logs = Get-EventLog -List | ForEach-Object {$_.Log}
$logs | ForEach-Object {Clear-EventLog -LogName $_ }
#Get-EventLog -ComputerName $computername -list



# launch the Windows Event Viewer, skip the double quotes for some reason
C:\Windows\system32\mmc.exe C:\Windows\system32\eventvwr.msc
dsregcmd /debug

# multiple DCs - sysvol replication?
# diagnose domain controller - runs a series of checks

# show only errors:
dcdiag /q

# show everything, super verbose
dcdiag /v


# Starting test: DFSREvent
# There are warning or error events within the last 24 hours after the SYSVOL has been shared.  Failing SYSVOL replication problems may cause Group
# Policy problems.
#https://social.technet.microsoft.com/Forums/lync/en-US/0ec565d4-2b9e-4fde-9bf0-b6f31d5a7000/dcdiag-there-are-warning-or-error-events-within-the-last-24-hours-after-the-sysvol-has-been-shared?forum=winserverDS

# Removing the second domain controller
# https://techcommunity.microsoft.com/t5/itops-talk-blog/step-by-step-manually-removing-a-domain-controller-server/ba-p/280564
# https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-




#The management agent "int.butters.me" step execution completed on run profile "Export" with errors.
 
# Additional Information
# Discovery Errors       : "0"
# Synchronization Errors : "0"
# Metaverse Retry Errors : "0"
# Export Errors          : "4"
# Warnings               : "0"
# User Action
# View the management agent run history for details.

#Error: 0xCAA9001F Integrated Windows authentication supported only in federation flow.
# https://docs.microsoft.com/en-us/troubleshoot/mem/intune/mdm-enrollment-error-0xcaa9001f


# signed up for AAD service and very slowly deployed those 2 VMs with load balancer
#TenantInfo::Discover: Failed reading registration data from AD. Defaulting to autojoin disabled 0x80070002
#DsrCmdJoinHelper::Join: TenantInfo::Discover failed with error code 0x801c001d.
#DSREGCMD_END_STATUS
 

#The guid-based DNS name is not registered on one or more DNS servers.



# To resume replication of this folder, use the DFS Management snap-in to remove this server from the replication group, and then add it back to the group. This causes the server to perform an initial synchronization task, which replaces the stale data with fresh data from other members of the replication group. 
 
# Additional Information: 
# Error: 9061 (The replicated folder has been offline for too long.) 
# Replicated Folder Name: SYSVOL Share 
# Replicated Folder ID: 3DADD44D-B89D-4E00-9FC6-DD98F8DC2142 
# Replication Group Name: Domain System Volume 
# Replication Group ID: 59480798-EA67-45FB-8F31-51C69B70D33C 
# Member ID: 7513CE7B-61A2-4E27-B43C-FF1CEF1C5646


# Solving Windows Server error code 1023
# DC02	1023	Error	Microsoft-Windows-Perflib	Application	4/16/2022 7:00:09 PM
# https://answers.microsoft.com/en-us/windows/forum/all/error-event-1023-source-perflib/b6ce52a7-cfda-4171-b243-2607d2bb32d1
# Windows cannot load the extensible counter DLL "C:\Windows\system32\ntdsperf.dll" (Win32 error code The specified module could not be found.).
# Didn't work since key wasn't there
#HKLMSYSTEMCurrentControlSetServicesServiceNamePerformance


#Configuration refresh failed with the following error: The metadata failed to be retrieved from the server, due to the following error: WinRM cannot process the request. The following error occurred while using Kerberos authentication: Cannot find the computer Verify that the computer exists on the network and that the name provided is spelled correctly. 


# Searching all of AD's global catalog
(New-Object adsisearcher ([adsi] "LDAP://CN=Schema,CN=Configuration,DC=int,DC=butters,DC=me", "(objectclass=attributeSchema)")).FindAll()  | Out-GridView

# Last remaining error in dcdiag as of 4/17 @ 5am
# Windows event code 4012
# Starting test: DFSREvent There are warning or error events within the last 24 hours after the SYSVOL has been shared.  Failing SYSVOL replication problems may cause Group Policy problems. failed test DFSREvent
# The DFS Replication service stopped replication on the folder with the following local path: C:\Windows\SYSVOL\domain. This server has been disconnected from other partners for 537 days, which is longer than the time allowed by the MaxOfflineTimeInDays parameter (60). DFS Replication considers the data in this folder to be stale, and this server will not replicate the folder until this error is corrected. 
 
# To resume replication of this folder, use the DFS Management snap-in to remove this server from the replication group, and then add it back to the group. This causes the server to perform an initial synchronization task, which replaces the stale data with fresh data from other members of the replication group. 
 
# Additional Information: 
# Error: 9061 (The replicated folder has been offline for too long.) 
# Replicated Folder Name: SYSVOL Share 
# Replicated Folder ID: 3DADD44D-B89D-4E00-9FC6-DD98F8DC2142 
# Replication Group Name: Domain System Volume 
# Replication Group ID: 59480798-EA67-45FB-8F31-51C69B70D33C 
# Member ID: 7513CE7B-61A2-4E27-B43C-FF1CEF1C5646

# https://community.spiceworks.com/topic/1892613-event-id-4012-failed-sysvol-replication-on-a-standalone-dc

# restarted at 5:12 am


dsregcmd /status
# AD Configuration Test : FAIL [0x80070002]

# when trying to dsregcmd /debug /join
# TenantInfo::Discover: Failed reading registration data from AD. Defaulting to autojoin disabled 0x80070002
# DsrCmdJoinHelper::Join: TenantInfo::Discover failed with error code 0x801c001d.
# DSREGCMD_END_STATUS
#              AzureAdJoined : NO
#           EnterpriseJoined : NO
# DeleteFileW returned 0x00000001.

# http://blog.petersenit.co.uk/2019/04/troubleshooting-azure-ad-hybrid-join.html
Start-ADSyncSyncCycle -PolicyType Delta 
# rebooted at 4/17/22 @ 5:47am
# waiting on rebot
# should check Event Log: Services / Microsoft /Windows / User Device Registration / Admin

# Automatic registration failed. Failed to lookup the registration service information from Active Directory. Exit code: Unknown HResult Error code: 0x801c001d. See http://go.microsoft.com/fwlink/?LinkId=623042

#!!!!!!!!! Hybrid Azure AD join isn't supported for Windows Server running the Domain Controller (DC) role.

# got the same error messages on the ias-scanengine1
# Windows event code 304

# Other errors maybe I'll look at
# NgcPreReq : ERROR 0xd0020017
# Client ErrorCode : 0x801c001d



#Error: 0xCAA2000B The resource is invalid due to configuration state or not existing.
#Code: invalid_resource
#Description: AADSTS500011: The resource principal named /cortana was not found in the tenant named buttersme. This can happen if the application has not been installed by the administrator of the tenant or consented to by any user in the tenant. You might have sent your authentication request to the wrong tenant.
#Trace ID: fb874df5-26d8-4727-adf3-0b4f8a164600
#Correlation ID: 915b0477-23b9-49f0-a1d5-e83016cb8bf3
#Timestamp: 2022-05-02 03:56:41Z
#TokenEndpoint: https://login.microsoftonline.com/common/oauth2/token
#Logged at oauthtokenrequestbase.cpp, line: 391, method: OAuthTokenRequestBase::ProcessOAuthResponse.

#Request: authority: https://login.microsoftonline.com/common, client: 26a7ee05-5602-4d76-a7ba-eae8b7b67941, redirect URI: ms-appx-web://Microsoft.AAD.BrokerPlugin/S-1-15-2-1861897761-1695161497-2927542615-642690995-327840285-2659745135-2630312742, resource: /cortana, correlation ID (request): 915b0477-23b9-49f0-a1d5-e83016cb8bf3
# https://docs.microsoft.com/en-us/answers/questions/293463/invalid-resource-aadsts500011.html

# actual tennat id 1cce68f2-33f1-40a7-b5e7-d24285a15c49