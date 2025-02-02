param
(
    [Parameter(Mandatory=$true, HelpMessage="Enter Azure Subscription name. You need to be Subscription Admin to execute the script")]
    [string] $subscriptionName,

    [Parameter(Mandatory=$true, HelpMessage="Provide a password for SPN application that you would create")]
    [string] $password,    

    [Parameter(Mandatory=$true, HelpMessage="Provide the name of the resourcegroup where the principal has access to")]
    [string] $resourceGroupName,

    [Parameter(Mandatory=$false, HelpMessage="Provide a SPN role assignment")]
    [string] $spnRole = "owner"
)

#Initialize
$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"
$userName = $env:USERNAME
$newguid = [guid]::NewGuid()
$displayName = [String]::Format("SP.{0}.{1}", $resourceGroupName, $newguid)
$homePage = "http://" + $displayName
$identifierUri = $homePage


#Initialize subscription
$isAzureModulePresent = Get-Module -Name Az* -ListAvailable
if ([String]::IsNullOrEmpty($isAzureModulePresent) -eq $true)
{
    Write-Output "Script requires Az modules to be present. Obtain Az from https://github.com/Azure/azure-powershell/releases. Please refer https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/DeployAzureResourceGroup/README.md for recommended Az versions." -Verbose
    return
}

Import-Module -Name Az.Profile
Write-Output "Provide your credentials to access Azure subscription $subscriptionName" -Verbose
Login-AzAccount -Subscription $subscriptionName
$azureSubscription = Get-AzSubscription -SubscriptionName $subscriptionName
$connectionName = $azureSubscription.SubscriptionName
$tenantId = $azureSubscription.TenantId
$id = $azureSubscription.SubscriptionId


#Create a new AD Application
Write-Output "Creating a new Application in AAD (App URI - $identifierUri)" -Verbose
$azureAdApplication = New-AzADApplication -DisplayName $displayName -HomePage $homePage -IdentifierUri $identifierUri -Password $password -Verbose
$appId = $azureAdApplication.ApplicationId
Write-Output "Azure AAD Application creation completed successfully (Application Id: $appId)" -Verbose


#Create new SPN
Write-Output "Creating a new SPN" -Verbose
$spn = New-AzADServicePrincipal -ApplicationId $appId
$spnName = $spn.ServicePrincipalName
Write-Output "SPN creation completed successfully (SPN Name: $spnName)" -Verbose


#Assign role to SPN
Write-Output "Waiting for SPN creation to reflect in Directory before Role assignment"
Start-Sleep 20
Write-Output "Assigning role ($spnRole) to SPN App ($appId)" -Verbose
New-AzRoleAssignment -RoleDefinitionName $spnRole -ApplicationId $appId -ResourceGroupName $resourceGroupName
Write-Output "SPN role assignment completed successfully" -Verbose


#Print the values
Write-Output "`nCopy and Paste below values for Service Connection" -Verbose
Write-Output "***************************************************************************"
Write-Output "Connection Name: $connectionName(SPN)"
Write-Output "Subscription Id: $id"
Write-Output "Subscription Name: $connectionName"
Write-Output "Service Principal Id: $appId"
Write-Output "Service Principal key: <Password that you typed in>"
Write-Output "Tenant Id: $tenantId"
Write-Output "***************************************************************************"