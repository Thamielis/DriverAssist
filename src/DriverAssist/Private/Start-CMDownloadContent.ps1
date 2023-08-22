#region Function Start-CMDownloadContent
function Start-CMDownloadContent {
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
        [Parameter(Mandatory = $true, ParameterSetName = "NoPath", HelpMessage = "Specify a PackageID that will be downloaded.")]
        [Parameter(ParameterSetName = "CustomPath")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^[A-Z0-9]{3}[A-F0-9]{5}$")]
        [string]$PackageID,
        [parameter(Mandatory = $true, ParameterSetName = "NoPath", HelpMessage = "Specify the download location type.")]
        [Parameter(ParameterSetName = "CustomPath")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Custom", "TSCache", "CCMCache")]
        [string]$DestinationLocationType,
        [parameter(Mandatory = $true, ParameterSetName = "NoPath", HelpMessage = "Save the download location to the specified variable name.")]
        [Parameter(ParameterSetName = "CustomPath")]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationVariableName,
        [parameter(Mandatory = $true, ParameterSetName = "CustomPath", HelpMessage = "When location type is specified as Custom, specify the custom path.")]
        [ValidateNotNullOrEmpty()]
        [string]$CustomLocationPath
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        #region OSDPHASE
        if ($env:SYSTEMDRIVE -eq 'X:') { $osdPhase = 'WinPE' }
        else { $osdPhase = 'Windows' }
        #endregion OSDPHASE
    }
    process {
        # Set OSDDownloadDownloadPackages
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDownloadPackages to: $($PackageID)" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Name "OSDDownloadDownloadPackages" -Value "$($PackageID)"
        # Set OSDDownloadDestinationLocationType
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationLocationType to: $($DestinationLocationType)" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Name "OSDDownloadDestinationLocationType" -Value "$($DestinationLocationType)"
		# Set OSDDownloadDestinationVariable
		Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationVariable to: $($DestinationVariableName)" -Severity 1 -Source ${CmdletName}
		Set-TSVariable -Value "$($DestinationVariableName)" -Name "OSDDownloadDestinationVariable"
		# Set OSDDownloadDestinationPath
		if ($DestinationLocationType -like "Custom") {
			Write-LogEntry -Value " - Setting task sequence variable OSDDownloadDestinationPath to: $($CustomLocationPath)" -Severity 1 -Source ${CmdletName}
			Set-TSValue -Variable "OSDDownloadDestinationPath" -Value "$($CustomLocationPath)"
		}
		# Set SMSTSDownloadRetryCount to 1000 to overcome potential BranchCache issue that will cause 'SendWinHttpRequest failed. 80072efe'
		Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 1000
		try {
            if ($osdPhase = 'WinPE') {
				Write-LogEntry -Value "[+] Starting package content download process ($($osdPhase)), this might take some time" -Severity 1
				$returnCode = Start-Executable -FilePath "OSDDownloadContent.exe"
			}
            else {
                Write-LogEntry -Value "[+] Starting package content download process ($($osdPhase)), this might take some time" -Severity 1 -Source ${CmdletName}
                $returnCode = Start-Executable -FilePath (Join-Path -Path $env:WINDIR -ChildPath "CCM\OSDDownloadContent.exe")
            }
            # Reset SMSTSDownloadRetryCount to 5 after attempted download
			Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 5
            # Match on return code
            if ($returnCode -eq 0) {
                Write-LogEntry -Value "[+] Successfully downloaded package content with PackageID: $($PackageID)" -Severity 1 -Source ${CmdletName}
            }
            else {
                Write-LogEntry -Value "[!] Failed to download package content with PackageID '$($PackageID)'. Return code was: $($returnCode)" -Severity 3 -Source ${CmdletName}
                # Throw terminating error
                $PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
            }
        }
        catch {
            Write-LogEntry -Value "[!] An error occurred while attempting to download package content. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
            # Throw terminating error
            $PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
        }
    }
    end {
        return $returnCode
    }
}
#endregion Function Start-CMDownloadContent
