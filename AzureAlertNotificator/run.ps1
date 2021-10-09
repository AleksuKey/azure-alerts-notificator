using namespace System.Net

# Inputs.
param($Request, $TriggerMetadata)

# Define variables.
$webhook = '#{TEAMS_WEBHOOK}#'

# Code.
Write-Host "PowerShell HTTP trigger function processed a request."

$Request.Body
# Write-Host $TriggerMetadata

$json = $Request.Body | ConvertTo-Json -Depth 4 | ConvertFrom-Json
$summary = 'Alert ' + $json.data.essentials.monitorCondition + ': ' + $json.data.essentials.alertRule + ' with ' + $json.data.essentials.severity

$message_card= @{
    '@type'      = 'MessageCard'
	'@context'   = 'https://schema.org/extensions'
	'title'      = $json.data.essentials.severity + " - " + $json.data.essentials.alertRule
    'themeColor' = '0078D7'
    'summary'    = $summary
    'sections'   = @(
        @{
            'activityTitle'    = $summary
            'activitySubtitle' = 'Resource ID: ' + $json.data.essentials.alertTargetIDs
            'text'             = 'Kindly check this alert. :)'
        }
    )
    'potentialAction'  = @(
        @{
            '@type'   = 'OpenUri'
            'name'    = 'View in Azure Portal'
            'targets' = @(
                @{
                    'os'  = 'default'
                    'uri' = 'https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AlertDetailsTemplateBlade/alertId/' + [System.Web.HttpUtility]::UrlEncode($json.data.essentials.alertId)
                }
            )
        }
    )
}

$json_payload = $message_card | ConvertTo-Json -Depth 4

Write-Host $json_payload

Invoke-WebRequest -Uri $webhook -Method POST -Body $json_payload -ContentType "application/json"

# Output
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $json.body.data.essentials.alertId
})
