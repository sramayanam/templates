<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

#param(


 #[Parameter(Mandatory=$True)]
 #[string]
 $resourceGroupName = "srramspark";
 #,

 #[Parameter(Mandatory=$True)]
 #[string]
 $resourceGroupLocation = "South Central US";
 #,

 #[Parameter(Mandatory=$True)]
 #[string]
 $deploymentName = "srramsparkdep";
 #,

 #[string]
 $templateFilePath = "C:\Users\srram\Desktop\spark\template.json"
 
 #,

 #[string]
 $parametersFilePath = "C:\Users\srram\Desktop\spark\parameters.json"
#)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -Force;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
#Login-AzureRmAccount;


##############SNIPPET FOR MSFT SUBSCRIPTION#################

 $applicationid = "0f8b9dac-3954-4e82-83d3-020f9ed02884"   
 $tenantid = "72f988bf-86f1-41af-91ab-2d7cd011db47"
 $azurePassword = ConvertTo-SecureString "Lz8oq1dn" -AsPlainText -Force
 $creds = New-Object System.Management.Automation.PSCredential ($applicationid, $azurePassword)
 Add-AzureRmAccount -Credential $creds -ServicePrincipal -TenantId $tenantid
################SNIPPET FOR MSDN SUBSCRIPTION########################

 #$applicationid = "42cf51ae-b879-4931-a1dc-a500979ba18c"   
 #$tenantid = "50460471-2197-4938-8e96-0708f3384c45"
 #$azurePassword = ConvertTo-SecureString "Lz8oq1dn" -AsPlainText -Force
 #$creds = New-Object System.Management.Automation.PSCredential ($applicationid, $azurePassword)
 #Add-AzureRmAccount -Credential $creds -ServicePrincipal -TenantId $tenantid

$subscriptionId = (Get-AzureSubscription -Current).SubscriptionId;

# select subscription
#Write-Host "Selecting subscription '$subscriptionId'";

Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.storage","microsoft.hdinsight");
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
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;
}