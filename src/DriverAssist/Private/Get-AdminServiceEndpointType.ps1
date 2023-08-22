#region Function Get-AdminServiceEndpointType
function Get-AdminServiceEndpointType {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
    .INPUTS
    .OUTPUTS
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        #region OSDPHASE
        if ($env:SYSTEMDRIVE -eq 'X:') { $osdPhase = 'WinPE' }
        else { $osdPhase = 'Windows' }
        #endregion OSDPHASE
    }
    process {
        switch ($script:DeploymentMode) {
			"BareMetal" {
				if ($osdPhase -eq 'WinPE') {
					Write-LogEntry -Value "[i] Detected that script was running within a task sequence in WinPE phase, automatically configuring AdminService endpoint type" -Severity 1 -Source ${CmdletName}
					$script:AdminServiceEndpointType = "Internal"
				}
				else {
					Write-LogEntry -Value "[!] Detected that script was not running in WinPE of a bare metal deployment type, this is not a supported scenario" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
			}
			"Debug" { $script:AdminServiceEndpointType = "Internal" }
			default {
				Write-LogEntry -Value "[i] Attempting to determine AdminService endpoint type based on current active Management Point candidates and from ClientInfo class" -Severity 1 -Source ${CmdletName}
				# Determine active MP candidates by the type of MP they are
                $ActiveMPInternalCandidates = Get-WmiObject -Namespace "root\ccm\LocationServices" -Class "SMS_ActiveMPCandidate" -Filter 'Type = "Assigned"'
				$ActiveMPExternalCandidates = Get-WmiObject -Namespace "root\ccm\LocationServices" -Class "SMS_ActiveMPCandidate" -Filter 'Type = "Internet"'
				# Determine if ConfigMgr client has detected if the computer is currently on internet or intranet
				$CMClientInternet = ([wmi]"root\ccm:ClientInfo=@").InInternet
				switch ($CMClientInternet) {
					$true {
						if ($ActiveMPExternalCandidates.Count -ge 1) {
							$script:AdminServiceEndpointType = "External"
						}
						else {
							Write-LogEntry -Value "[!] Detected as an Internet client but unable to determine External AdminService endpoint, bailing out" -Severity 3 -Source ${CmdletName}
							$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
						}
					}
					$false {
						if ($ActiveMPInternalCandidates.Count -ge 1) {
							$script:AdminServiceEndpointType = "Internal"
						}
						else {
							Write-LogEntry -Value "[!] Detected as an Intranet client but unable to determine Internal AdminService endpoint, bailing out" -Severity 3 -Source ${CmdletName}
							$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
						}
					}
				}
			}
		}
		Write-LogEntry -Value "[+] Determined AdminService endpoint type as: $($AdminServiceEndpointType)" -Severity 1 -Source ${CmdletName}
    }
    end {
    }
}
#endregion Function Get-AdminServiceEndpointType
