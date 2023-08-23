#region Function Confirm-Architecture
function Confirm-Architecture {
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
        [parameter(Mandatory = $true, HelpMessage = "Specify the Architecture value from the driver package object.")]
        [ValidateNotNullOrEmpty()]
        [string]$DriverPackageInput,
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$OSImageData
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        if ($DriverPackageInput -like $OSImageData.Architecture) {
			# OS architecture match found
			Write-LogEntry -Value "[+] Matched operating system architecture: $($OSImageData.Architecture)" -Severity 1 -Source ${CmdletName}
			return $true
		}
		else {
			# OS architecture match was not found
			Write-LogEntry -Value "[!] Could not match operating system architecture: $($OSImageData.Architecture)" -Severity 2 -Source ${CmdletName}
			return $false
		}
    }
    end {
    }
}
#endregion Function Confirm-Architecture
