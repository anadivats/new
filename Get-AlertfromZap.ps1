<#
    .Synopsis
    This script will give alerts from ZAP 
    .Example
    .\Get-AlertfromZap        
    .Notes
     Author: Mrityunjaya Pathak
     Date : Feb 2015
        
#>
param(
 #Url on which ZAP operation will be performed(only http url)
 $URL=$(throw 'Missing filepath value'),
 #ZAP Proxy URI
 $PROXY='http://localhost:8080',
 $AlertCount=$(throw 'Missing Alert Count value'),
 $BatchSize=5,
 $progressID=(Get-Random)
)

Add-CurrentScriptFolderToPath
$ErrorActionPreference='stop'
$count=0
$TotalAlerts=@()

while($count -lt $AlertCount)
{
    
    $status=($count/$AlertCount*100)%100
     write-progress -activity 'Getting report from zap attack ' -status "$status% Complete:" -percentcomplete $status -id $progressID
    $ZapURL='http://zap/JSON/core/view/alerts/?zapapiformat=JSON&baseurl='+$URL+'&start='+$count+'&count='+$BatchSize
    Invoke-ZapApirequest $ZapURL -Proxy $PROXY | Select-Object -expand content |Convertfrom-json|Set-Variable alerts
    $count+=$BatchSize
    $TotalAlerts+=$alerts
}
Write-Progress -id $progressID ZAPStatus ZapStatus -Completed
$TotalAlerts.Alerts|select-object URL,Attack,Alert,Risk,Reliablity,Param|Set-Variable ReportAlert 

Remove-FalseZapPositive $ReportAlert |Set-Variable filteredAlerts

$filteredAlerts