<#
    .Synopsis
     This script will remove false positives so that the scan result has only vluable information.
    .DESCRIPTION
     Generated  alerts will be matched with the list of safe URL's and untrusted URL's will be marked
    .Example
     .\Remove-FalseZapPositive
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    # List of safe URL's in sharepoint 
    $Messages
)


function match($sb) {

    if ($messages) {
       $messages | group $sb -AsString -AsHashTable | sv result
 $Removed+=$result.true 
   write-host "matched $($result.true.count) - left $($result.false.count) - $sb"
 $messages=$result.false
    }


}

$removed=@()

. match {$_.alert -ne 'Cross-domain JavaScript source file inclusion'}    # Remove all alerts except Cross-domain JavaScript source file inclusion
. match {$_.param -match '^https?://a248\.e\.akamai(-staging)?\.net/'} 
. match {$_.param -match '^https?://(([\w\.\-]+)\.)?lego\.(com|cn)/'} 
. match {$_.param -match '^https?://([\w\.\-]+)\.legocdn\.(com|cn)/'} 
. match {$_.param -match '^https?://([\w\.\-]+)\.lego\.com\.edgesuite(-staging)?\.net/'} 

$messages
#'removed'
#$removed
