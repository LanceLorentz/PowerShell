Function Test-System
{
[CmdletBinding()]
$IpAddress = Get-NetIPAddress | Where-Object -Property 'InterfaceAlias' -EQ 'Wi-Fi'
$Ping = Test-NetConnection Google.com
$Properties = @{
                'IPv4_Address' = $IpAddress.IPv4Address;
                'IPv6_Address' = $IpAddress.IPv6Address;
                'Internet_Connection' = $Ping.PingSucceeded
               }
$Output = New-Object -TypeName PSObject -Property $Properties
Write-Output $Output
<#
.SYNOPSIS
This command returns basic information regarding the local systems network connectivity.
.DESCRIPTION 
This command retunrs the following information:
    - IPv4 Address
    - IPv6 Address
    - Internet Connectivity Status (True/False)
            - Performs a Test-NetConnection to Google.com to verify internet connectivity
This command functions only for the local host.
#>     
}
