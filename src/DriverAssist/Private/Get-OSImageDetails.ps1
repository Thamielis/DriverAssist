#region Function Get-OSImageDetails
function Get-OSImageDetails {
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
    }
    process {
        switch ($script:DeploymentMode) {
			"DriverUpdate" {
				$OSImageDetails = [PSCustomObject]@{
					Architecture = Get-OSArchitecture -InputObject (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty OSArchitecture)
					Name = $script:TargetOSName
					Version = Get-OSBuild -InputObject (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version) -OSName $script:TargetOSName
				}
			}
			default {
				$OSImageDetails = [PSCustomObject]@{
					Architecture = $script:TargetOSArchitecture
					Name = $script:TargetOSName
					Version = $script:TargetOSVersion
				}
			}
		}
		Write-LogEntry -Value "[i] Target operating system name configured as: $($OSImageDetails.Name)" -Severity 1 -Source ${CmdletName}
		Write-LogEntry -Value "[i] Target operating system architecture configured as: $($OSImageDetails.Architecture)" -Severity 1 -Source ${CmdletName}
		Write-LogEntry -Value "[i] Target operating system version configured as: $($OSImageDetails.Version)" -Severity 1 -Source ${CmdletName}
    }
    end {
		return $OSImageDetails
    }
}
#endregion Function Get-OSImageDetails
