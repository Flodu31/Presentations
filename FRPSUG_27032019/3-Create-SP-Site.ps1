# Not supported on Mac
# Create the site
# Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Import-Module -Name Microsoft.Online.SharePoint.PowerShell
$adminUPN="admin@florentappointaire.onmicrosoft.com"
$orgName="florentappointaire.onmicrosoft.com"
$url="https://florentappointaire.sharepoint.com/sites/FRPSUG2703"
$urlAdmin="https://florentappointaire-admin.sharepoint.com"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url $urlAdmin -Credential $userCredential
New-SPOSite -Owner $adminUPN -StorageQuota 100 -Url $url -NoWait -Template "PROJECTSITE#0" -TimeZoneID 10 -Title "French PowerShell User Group"