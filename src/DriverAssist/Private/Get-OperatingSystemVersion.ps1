#region Function Get-OperatingSystemVersion
function Get-OperatingSystemVersion {
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
        if (($script:PSCmdlet.ParameterSetName -like "DriverUpdate") -or ($script:PSCmdlet.ParameterSetName -like "OSUpgrade")) {
			$OperatingSystemVersion = Get-WmiObject -Class "Win32_OperatingSystem" | Select-Object -ExpandProperty "Version"
			if ($OperatingSystemVersion -like "10.0.*") {
				Write-LogEntry -Value "[+] Supported operating system version currently running detected, script execution allowed to continue" -Severity 1 -Source ${CmdletName}
			}
			else {
				Write-LogEntry -Value "[!] Unsupported operating system version detected, this script is only supported on Windows 10 and above" -Severity 3 -Source ${CmdletName}
				$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
			}
		}
    }
    end {
    }
}
#endregion Function Get-OperatingSystemVersion
