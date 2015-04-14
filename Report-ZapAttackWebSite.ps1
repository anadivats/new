<#
    .Synopsis    
     This Script will Generate Report of Active Scan from ZAP and will contain url,attack,alert,risk,reliablity.
    .Example
     .\Report-ZapAttackWebSite
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Url on which ZAP operation will be performed(only http url)
    $URL =$(throw 'Missing filepath value'),
    #ZAP Proxy URI    
    $proxy='http://localhost:8080',
    $start='',
    $count=''
)
Add-CurrentScriptFolderToPath
$ErrorActionPreference='stop'
Invoke-ZapAttackWebSite $url
$AlertCount= Get-AlertCount $url
&$PSScriptRoot\Get-AlertFromZap $URL $PROXY $AlertCount  | sv ReportAlert

#$ReportAlert|Export-Clixml 'CrossSiteScript.Clixml'
#$ReportAlert|Export-Csv 'CrossSiteScript.csv'

@"
    This report contains a list of defects found at $url which needs to be fixed.
    Following  are fields used for creating this report. 
    Alert: This isa defect type. e.g. cross-site script inclusion.
    Param : Defect Value. In case of cross-site script Inclusion it will  be a url of third party script.
    Recommendation : A solution which can help in resolving this problem.
    
    $($ReportAlert|fl Alert, Param, Recommendation |out-string )
"@|out-file test.txt
    
