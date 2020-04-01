#=====================================================================================================================================
#
# NAME: One script to deploy anywhere (Azure/AzureStack)
#
# AUTHOR: Florent APPOINTAIRE
# DATE: 15/09/2016
# VERSION: 1.0
#
# COMMENT: Requires Azure PowerShell 1.2.0. to work on Azure Stack POC TP1. This version can be found here: 
# https://github.com/Azure/azure-powershell/releases/tag/v1.2.0-February2016
# SubscriptionId: 4934d8d9-8898-4f79-8486-1edc7840e54d
# Connection Account: florent.appointaire@devoteam.be
# VMName: floappexp16
#
#=====================================================================================================================================

#region PARAMETERS
param(
 [Parameter(Mandatory=$true)]
 [string]
 $resourceGroupName,

 [Parameter(Mandatory=$True)]
 [string]
 $StorageAccountName,

 [Parameter(Mandatory=$True)]
 [string]
 $vmName,

 [Parameter(Mandatory=$True)]
 [string]
 $adminUsername,

 [Parameter(Mandatory=$True)]
 [string]
 $dnsNameForPublicIP,

 [string]
 $deploymentLocation,

 [string]
 $vmSize,

 [string]
 $blobStorageEndpoint
)
#endregion

#region FUNCTIONS

Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -Force;
}
#endregion

#region Select Azure or Azure Stack

[int]$xMenuChoiceA = 0
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 2 ){
Write-Host "`t`t- Select the cloud region your are deploying to. -`n" -Fore Yellow
Write-host "1. Azure" -ForegroundColor Cyan
Write-host "2. Azure Stack" -ForegroundColor Cyan
[Int]$xMenuChoiceA = 
read-host "Enter option 1 or 2"
} 
Switch( $xMenuChoiceA )
  {
  1
  {

#endregion

#region Azure Begin
# Login
Write-Host "Logging in..." -ForegroundColor Blue;
Login-AzureRmAccount;

$subscriptionId = read-host "Enter Subscription Id"
$blobStorageEndpoint = "blob.core.windows.net"
$templateFilePath = "AzureandAzureStack.json"
$parametersFilePath = "AzureandAzureStackparameters.json"
$vmSize = "Standard_D1"

# select subscription
Write-Host "Selecting subscription '$subscriptionId'" -ForegroundColor Yellow;
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

$ErrorActionPreference = "Stop"

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation (Valid Values are: northeurope, westeurope, uksouth, ukwest)";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

$deploymentLocation = "$resourceGroupLocation"


# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -deploymentLocation $deploymentLocation -blobStorageEndpoint $blobStorageEndpoint -StorageAccountName $StorageAccountName -vmName $vmName -vmSize $vmSize -dnsNameForPublicIP $dnsNameForPublicIP -adminUsername $adminUsername;
} else {
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -deploymentLocation $deploymentLocation -blobStorageEndpoint $blobStorageEndpoint -StorageAccountName $StorageAccountName -vmName $vmName -vmSize $vmSize -dnsNameForPublicIP $dnsNameForPublicIP -adminUsername $adminUsername;
    }

Write-Host "Your virtual machine has been deployed successfully on Azure." -ForegroundColor Yellow
#Write-Host "Your virtual machine has been deployed successfully. Launching https://portal.azure.com to view the new deployment." -ForegroundColor Yellow

#Start-Process -FilePath https://portal.azure.com

  }
  2
  {
#endregion Azure End

#region Azure Stack Begin
# Add the Microsoft Azure Stack environment

$AadtenantId="devocenter.onmicrosoft.com"
Add-AzureRmEnvironment -Name 'Azure Stack' `
    -ActiveDirectoryEndpoint ("https://login.windows.net/$AadTenantId/") `
    -ActiveDirectoryServiceEndpointResourceId "https://azurestack.local-api/"`
    -ResourceManagerEndpoint ("https://api.azurestack.local/") `
    -GalleryEndpoint ("https://gallery.azurestack.local/") `
    -GraphEndpoint "https://graph.windows.net/"

$myLocation = "local"
$blobStorageEndpoint = "blob.azurestack.local"
$templateFilePath = "AzureandAzureStack.json"
$parametersFilePath = "AzureandAzureStackparameters.json"
$vmSize = "Standard_A1"
$deploymentLocation = "$myLocation"


# Setup and Configure Connection for Azure Stack Environment (you will be prompted during authentication)
Write-Host "Logging in..." -ForegroundColor Blue;
$privateEnv = Get-AzureRmEnvironment 'Azure Stack'
$privateAzure = Add-AzureRmAccount -Environment $privateEnv

# Authenticate a user to the environment
Select-AzureRmProfile -Profile $privateAzure
Get-AzureRmSubscription -SubscriptionName "Experiences 16"  | Select-AzureRmSubscription

$ErrorActionPreference = "Stop"

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
if($resourceProviders.length) {
    Write-Host "Registering resource providers" -ForegroundColor Yellow
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    #Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location." -ForegroundColor Yellow;
    if(!$myLocation) {
        $myLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$myLocation'" -ForegroundColor Yellow;
    New-AzureRmResourceGroup -Name "$resourceGroupName" -Location $myLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'" -ForegroundColor Yellow;
}

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -deploymentLocation $deploymentLocation -blobStorageEndpoint $blobStorageEndpoint -StorageAccountName $StorageAccountName -vmName $vmName -vmSize $vmSize -dnsNameForPublicIP $dnsNameForPublicIP -adminUsername $adminUsername;
} else {
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -deploymentLocation $deploymentLocation -blobStorageEndpoint $blobStorageEndpoint -StorageAccountName $StorageAccountName -vmName $vmName -vmSize $vmSize -dnsNameForPublicIP $dnsNameForPublicIP -adminUsername $adminUsername;
    }

Write-Host "Your virtual machine has been deployed successfully on Azure Stack." -ForegroundColor Yellow
#Write-Host "Your virtual machine has been deployed successfully. Launching https://portal.azurestack.local to view the new deployment." -ForegroundColor Yellow

#Start-Process -FilePath https://portal.azurestack.local


  }
  default
  {
#endregion

#region Default
# Login
Write-Host "Logging in..." -ForegroundColor Blue;
Login-AzureRmAccount;

# Select subscription
Write-Host "Selecting subscription '$subscriptionId'" -ForegroundColor Yellow;
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

  }
}
#endregion