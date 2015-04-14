<#
    .Synopsis
    This script will call Start-Zap script to start active session of ZAP and will start spidering on given url
    .Example
    .\Invoke-ZapAttackWebsite [ZAP Folder path] [Url to attack]
    This will start the session of ZAP and will attack given http url.
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(

    #Url on which ZAP operation will be performed(only http url)
    $URL =$(throw 'Missing filepath value'),
    #Zap.jar folder location 
    $path = 'C:\Program Files (x86)\OWASP\Zed Attack Proxy',
    #use inScopeOnly=true if you have declared one or more contexts   
    $scope='true',
    #use recurse=true to scan the subtree
    $recurse='true',
    #ZAP Proxy URI
    $proxy='http://localhost:8080',
    $sleep=1
)
Add-CurrentScriptFolderToPath
$ErrorActionPreference='stop'
$spideringStatus=Invoke-ZapApiRequest 'http://zap/JSON/spider/view/status/?zapapiformat=JSON' $proxy|ConvertFrom-Json
if($spideringStatus.status -ne 100){
    Write-Error "`nSpidering on $url is not yet done or 100% completed. `nPrerequisite: Run Invoke-ZapScanWebsite before running this script.`n"   
}
[Reflection.Assembly]::LoadFile( `
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Web.dll')`
  | out-null 
$zapurl ='http://zap/JSON/ascan/action/scan/?zapapiformat=JSON&url='+[System.Web.HttpUtility]::UrlEncode($URL)+'&recurse='+$recurse+'&inScopeOnly='+$scope
$ActiveScan=Invoke-ZapApiRequest $zapurl $proxy
do{
    Start-Sleep -s $sleep
    $count +=1
    $Result=Invoke-ZapApiRequest 'http://zap/JSON/ascan/view/status/?zapapiformat=JSON' $proxy | ConvertFrom-Json
    $status=$Result.status
    if(!$status){
        break
    }
     write-progress -activity 'Attack in Progress' -status "$status% Complete:" -percentcomplete $status;
    
}while($status -ne '100' )
if($status -ne 100 ){
    Write-error "Attack on '$url' aborted because ZAP API stopped responding: Result : '$result'"
}
else{
    Write-Host 'Attack on ' $url ' completed'
}
