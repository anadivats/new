<#
    .Synopsis
    This script will start the  session of ZAP
    .Example
    .\Start-Zap [ZAP Folder path] [Url to attack]
    This will start the session of ZAP and will attack given http url.
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Zap.jar folder location 
    $path = 'C:\Program Files (x86)\OWASP\Zed Attack Proxy',
    #ZAP Proxy URI
    $proxy='http://localhost:8080',
    $sleep=1,
    #Maximum Wait Time for ZAP
    [Timespan]$MaxWaitInterval='0:1:0',
    $ProgressID=(Get-Random)
)
Add-CurrentScriptFolderToPath
$ErrorActionPreference='stop'
stop-zap $proxy $sleep
Push-Location $path
.\zap.jar 
Pop-Location 
$count=0
$status=0
$endAt=(get-date)+$MaxWaitInterval
while((get-date) -le $endAt){
   
    $status=Invoke-ZapApiRequest 'http://zap/' $proxy
    if($status.StatusCode -eq 200){
        $zapstarted=$true
        break
    }
    Write-Progress -id $ProgressID -SecondsRemaining (($endAt - (get-date)).TotalSeconds) 'Waiting for ZAP to start'
    Start-Sleep -s $sleep
}
Write-Progress -id $ProgressID ZAPStatus ZapStatus -Completed
if($zapstarted){
    Invoke-ZapApiRequest 'http://zap/JSON/core/action/newSession/?zapapiformat=JSON&name=&overwrite=' $proxy |Out-Null
}
else{
    Write-Error 'Zap unable to start'
}