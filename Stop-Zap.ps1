<#
    .Synopsis
    This script will stop the active session of ZAP
    .Example
    .\Stop-Zap [Proxy for ZAP]
    This will stop and close ZAP session
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #ZAP Proxy URI
    $proxy='http://localhost:8080',
    $sleep=1,
    #Maximum Wait Time for ZAP
    [Timespan]$MaxWaitInterval='0:1:0',
    [switch] $KillOnly 
)
function Stop-ZapProcess
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
        .EXAMPLE
        Stop-ZapProcess
        explains how to use the command
        can be multiple lines
        .EXAMPLE
        Stop-ZapProcess
        another example
        can have as many examples as you like
    #>
    $process =Get-WmiObject win32_process |Where-Object processname -match javaw  |Where-Object commandLine -match zap | Select-Object processid  
    if( $process.processid -gt 0){
        stop-process $process.processid
    }   
}
Add-CurrentScriptFolderToPath
$ErrorActionPreference='stop'
if($KillOnly.IsPresent){
    Stop-ZapProcess
    Write-host 'Zap stopped'
}
else{
    Invoke-ZapApiRequest 'http://zap/JSON/core/action/shutdown/?zapapiformat=JSON' $proxy|Out-Null
    $endAt=(get-date)+$MaxWaitInterval
    while((get-date) -le $endAt){
        $status=Invoke-ZapApiRequest 'http://zap/' $proxy -KillZapOnError
        write-host $status.StatusCode
        if(!$status.StatusCode){
            $zapstopped=$true
            break
        }
        Write-Host 'o'
        Start-Sleep -s $sleep
    }
    if(!$zapstopped){
        Stop-ZapProcess
     }
     else{
        Write-host 'Zap stopped'
     }
    }



  