param (
    [string]$webhook
)

Write-Host "Adding Teams Webhook URL inside ./AzureAlertNotificator/run.ps1"
(Get-Content ./AzureAlertNotificator/run.ps1).Replace('#{TEAMS_WEBHOOK}#', $webhook) | Set-Content ./AzureAlertNotificator/run.ps1