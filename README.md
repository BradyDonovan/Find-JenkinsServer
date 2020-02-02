# Find-JenkinsServer
Find Jenkins servers on the network with PowerShell. Sends a small UDP datagram to the local broadcast address or multicast address to find Jenkins, assuming that auto-discover is enabled. Written as a function so it can be dot-sourced or implemented in a larger script. See the following for more details on auto-discover: https://wiki.jenkins.io/display/JENKINS/Auto-discovering+Jenkins+on+the+network

# Usage
(from PowerShell)
```powershell
. .\Find-JenkinsServer.ps1
Find-JenkinsServer -Broadcast
Find-JenkinsServer -Multicast
```
