#region Function Reset-CMDownloadContentVars
function Reset-CMDownloadContentVars {
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
        # Set OSDDownloadDownloadPackages
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDownloadPackages to a blank value" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Name "OSDDownloadDownloadPackages" -Value [System.String]::Empty
		# Set OSDDownloadDestinationLocationType
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationLocationType to a blank value" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Name "OSDDownloadDestinationLocationType" -Value [System.String]::Empty
		# Set OSDDownloadDestinationVariable
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationVariable to a blank value" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Name "OSDDownloadDestinationVariable" -Value [System.String]::Empty
		# Set OSDDownloadDestinationPath
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationPath to a blank value" -Severity 1 -Source ${CmdletName}
        Set-TSVariable -Name "OSDDownloadDestinationPath" -Value [System.String]::Empty
    }
    end {
    }
}
#endregion Function Reset-CMDownloadContentVars
