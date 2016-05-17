$resourceGroupName = "rgsrram"
$resourceName = "storagefordemodfsrram"
# sign in
Write-Host "Logging in...";
#Login-AzureRmAccount;
$applicationid = "0f8b9dac-3954-4e82-83d3-020f9ed02884"   
$tenantid = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$azurePassword = ConvertTo-SecureString "Lz8oq1dn" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($applicationid, $azurePassword)
Add-AzureRmAccount -Credential $creds -ServicePrincipal -TenantId $tenantid
$subscriptionId = (Get-AzureSubscription -Current).SubscriptionId;
# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Set-AzureRmContext -SubscriptionID $subscriptionId;



Get-AzureRmResource -ResourceGroupName "rgsrram" -ResourceName $resourceGroupName -ResourceType "Microsoft.HDInsight/clusters"

$rgroupstatus = (Get-AzureRmResourceGroup -Name $resourceGroupName).ProvisioningState
if($rgroupstatus = "Succeeded")
{
Write-Host "Remove Resource Group";
##Remove-AzureRmResourceGroup -Name $resourceGroupName -Force
}
else
{
Write-Host "No Resource Group Exists";
}