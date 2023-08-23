#region Function Confirm-OSName
function Confirm-OSName {
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
        [parameter(Mandatory = $true, HelpMessage = "Specify the OS name value from the driver package object.")]
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
        if ($DriverPackageInput -like $OSImageData.Name) {
			# OS name match found
			Write-LogEntry -Value "[+] Matched operating system name: $($OSImageData.Name)" -Severity 1 -Source ${CmdletName}
			return $true
		}
		else {
			# OS name match was not found
			Write-LogEntry -Value "[!] Could not matched operating system name: $($OSImageData.Name)" -Severity 2 -Source ${CmdletName}
			return $false
		}
    }
    end {
    }
}
#endregion Function Confirm-OSName
