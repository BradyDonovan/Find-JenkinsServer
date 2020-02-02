function Find-JenkinsServer {
    <#
    .SYNOPSIS
    Confirms the presence of a Jenkins server on the local network.

    .DESCRIPTION
    Send a small UDP datagram to the local broadcast address or multicast address to find Jenkins.

    .EXAMPLE
    Find-JenkinsServer -Broadcast

    .EXAMPLE
    Find-JenkinsServer -Multicast

    .OUTPUTS
    If found, Find-JenkinsServer will return a Hashtable containing the 'Valid = $true' property and ServerInformation property. If invalid, Find-JenkinsServer will return nothing.

    .NOTES
    See the following for details:
        http://kohsuke.org/2010/05/14/auto-discovering-hudson-in-the-network/
        https://wiki.jenkins.io/display/JENKINS/Auto-discovering+Jenkins+on+the+network
    Contact information:
    https://github.com/BradyDonovan/
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Position = 0, Mandatory = $false, HelpMessage = "Use UDP broadcast.", ParameterSetName = "Broadcast")]
        [switch]$Broadcast,
        [Parameter(Position = 1, Mandatory = $false, HelpMessage = "Use UDP multicast.", ParameterSetName = "Multicast")]
        [switch]$Multicast
    )
    process {
        If ($Broadcast) {
            $targetIp = [System.Net.IPAddress]::Parse('255.255.255.255')
        }
        If ($Multicast) {
            $targetIp = [System.Net.IPAddress]::Parse('239.77.124.213')
        }
        If (!$Broadcast -and !$Multicast) {
            exit 1
        }
        #build ipEndpoint obj for $udpConnection.Receive
        $endpointObj = New-Object System.Net.IPEndPoint($targetIp, 33848)

        #create UDP Client
        $udpConnection = New-Object System.Net.Sockets.UdpClient
        $udpConnection.client.ReceiveTimeout = 10000
        $udpConnection.Client.SendTimeout = 10000

        #per specification, a UDP Datagram needs to be sent (https://wiki.jenkins.io/display/JENKINS/Auto-discovering+Jenkins+on+the+network)
        $sendByte = [System.Text.Encoding]::ASCII.GetBytes('Hey Jenkins, are you there?')

        #send (https://msdn.microsoft.com/en-us/library/82dxxas0(v=vs.110).aspx)
        $udpConnection.Send($sendByte, 0, $endpointObj)>$null

        #receive bytes
        Try {
            $receiveBytes = $udpConnection.Receive([ref]$endpointObj)
            [xml]$replyString = [System.Text.Encoding]::ASCII.GetString($receiveBytes)
            IF ($replyString) {
                Return @{
                    Valid             = $true
                    ServerInformation = $replyString
                }
            }
        }
        Catch {
            IF ($null -eq $receiveBytes) {
                Return @{
                    Valid             = $false
                    ServerInformation = $null
                }
            }
        }
    }
}
